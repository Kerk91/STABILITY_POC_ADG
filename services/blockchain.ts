"use server";

/**
 * @fileOverview Simplified blockchain service for Global Trust Network
 * Core operations: verify/read records and write new records
 */

// =============================================================================
// Types
// =============================================================================

export interface BlockchainRecord {
  fileName: string;
  fileHash: string;
  timestamp: number;
  category: string;
  data?: string;
}

// =============================================================================
// Configuration
// =============================================================================

const STABILITY_API =
  process.env.NEXT_PUBLIC_STABILITY_API ||
  "https://rpc.stabilityprotocol.com/zkt/try-it-out";

const CONTRACT_ADDRESS =
  process.env.NEXT_PUBLIC_CONTRACT_ADDRESS ||
  "0xf79Fc7F6e7C36DCeCD04e603515315528BA9AC72";

const CONTRACT_ABI = [
  "function getFile(bytes32 fileHash) view returns (tuple(address owner, string fileName, bytes32 fileHash, uint timestamp, bytes data, uint8 category) fileRecord, bool isReference, tuple(bytes32 originalFileHash, bytes32 modifiedFileHash, uint refTimestamp, bytes refData) referenceRecord)",
  "function storeFile(string fileName, bytes32 fileHash, bytes data, string categoryStr)",
];

const CATEGORY_MAP: Record<number, string> = {
  0: "Image",
  1: "Video",
  2: "Audio",
  3: "Others",
};

// =============================================================================
// Utility Functions
// =============================================================================

function hexBytesToString(hex: string): string {
  if (!hex || hex === "0x") return "";

  const cleanHex = hex.startsWith("0x") ? hex.substring(2) : hex;
  let result = "";

  for (let i = 0; i < cleanHex.length; i += 2) {
    const charCode = parseInt(cleanHex.substr(i, 2), 16);
    if (!isNaN(charCode)) {
      result += String.fromCharCode(charCode);
    }
  }

  return result;
}

function ensureHexPrefix(hash: string): string {
  return hash.startsWith("0x") ? hash : `0x${hash}`;
}

async function makeApiCall(method: string, args: unknown[]): Promise<any> {
  const response = await fetch(STABILITY_API, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      abi: CONTRACT_ABI,
      to: CONTRACT_ADDRESS,
      method,
      id: Date.now(),
      arguments: args, // Look at Readme.md for more information
    }),
  });

  if (!response.ok) {
    throw new Error(`API Error: ${response.status} ${response.statusText}`);
  }

  return response.json();
}

// =============================================================================
// Core Functions
// =============================================================================

/**
 * Verify/read a file record from the blockchain
 * @param fingerprint - SHA-256 hash of the file
 * @returns BlockchainRecord if found, null otherwise
 */
export async function verifyFile(
  fingerprint: string
): Promise<BlockchainRecord | null> {
  try {
    const formattedFingerprint = ensureHexPrefix(fingerprint);
    const result = await makeApiCall("getFile", [formattedFingerprint]);

    if (
      !result.success ||
      !Array.isArray(result.output) ||
      result.output.length !== 3
    ) {
      return null;
    }

    const [fileRecord] = result.output;
    const [owner, fileName, fileHash, timestamp, dataBytes, categoryIndex] =
      fileRecord;

    // Check if record exists (not zero values)
    const zeroAddress = "0x0000000000000000000000000000000000000000";
    const zeroHash =
      "0x0000000000000000000000000000000000000000000000000000000000000000";

    if (owner === zeroAddress || fileHash === zeroHash) {
      return null;
    }

    return {
      fileName,
      fileHash,
      timestamp: parseInt(timestamp, 10),
      category: CATEGORY_MAP[parseInt(categoryIndex, 10)] || "Unknown",
      data: hexBytesToString(dataBytes),
    };
  } catch (error) {
    console.error("Error verifying file:", error);
    return null;
  }
}

/**
 * Write a new file record to the blockchain
 * @param fileName - Name of the file
 * @param fingerprint - SHA-256 hash of the file
 * @param category - File category (image, video, audio, others)
 * @param metadata - Optional metadata string
 * @returns Transaction hash if successful, null otherwise
 */
export async function writeRecord(
  fileName: string,
  fingerprint: string,
  category: string,
  metadata: string = ""
): Promise<string | null> {
  try {
    const formattedFingerprint = ensureHexPrefix(fingerprint);
    const categoryLower = category.toLowerCase();

    // Convert metadata to hex bytes
    let metadataHex = "0x";
    if (metadata) {
      metadataHex = "0x" + Buffer.from(metadata, "utf8").toString("hex");
    }

    const result = await makeApiCall("storeFile", [
      fileName,
      formattedFingerprint,
      metadataHex,
      categoryLower,
    ]);

    if (result.success && result.hash?.startsWith("0x")) {
      return result.hash;
    }

    return null;
  } catch (error) {
    console.error("Error writing record:", error);
    return null;
  }
}
