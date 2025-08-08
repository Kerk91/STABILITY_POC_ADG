# STABILITY_POC - File Authentication on the Global Trust Network

This is a Next.js application that allows users to securely verify and manage file authenticity using blockchain technology through the Global Trust Network (GTN).

## 🔧 Configuration

Create a `.env` file based on `.env_sample`:

```bash
# Global Trust Network Configuration
NEXT_PUBLIC_STABILITY_API=https://rpc.stabilityprotocol.com/zkt/your_api_endpoint_here
NEXT_PUBLIC_CONTRACT_ADDRESS=0xYourContractAddressHere
```

## Blockchain Service API

The blockchain service provides two core functions for interacting with the Global Trust Network. All operations are handled through `services/blockchain.ts`.

### 🔍 `verifyFile(fingerprint)` - Read/Verify File Records

Checks if a file exists on the blockchain and retrieves its metadata.

**Parameters:**

- `fingerprint` (string): SHA-256 hash of the file (with or without 0x prefix)

**Returns:**

- `BlockchainRecord | null`: File record if found, null if not found

**Example Usage:**

```typescript
import { verifyFile } from "./services/blockchain";

const record = await verifyFile("abc123def456..."); // SHA-256 hash
if (record) {
  console.log(`File: ${record.fileName}`);
  console.log(`Category: ${record.category}`);
  console.log(`Timestamp: ${new Date(record.timestamp * 1000)}`);
} else {
  console.log("File not found on blockchain");
}
```

**📋 Sample cURL Command (click code block to select all):**

```bash
curl -X POST "https://rpc.stabilityprotocol.com/zkt/try-it-out" \
  -H "Content-Type: application/json" \
  -d '{
    "abi": ["function getFile(bytes32 fileHash) view returns (tuple(address owner, string fileName, bytes32 fileHash, uint timestamp, bytes data, uint8 category) fileRecord, bool isReference, tuple(bytes32 originalFileHash, bytes32 modifiedFileHash, uint refTimestamp, bytes refData) referenceRecord)"],
    "to": "0xf79Fc7F6e7C36DCeCD04e603515315528BA9AC72",
    "method": "getFile",
    "id": 1678886400000,
    "arguments": ["0x8687fa37d02e6d2ce4a27dcd5cb36caf0fac1e26c9879df46a00e4d009c1dab1"]
  }'
```

> 💡 **Tip:** Click inside the code block above, then use `Ctrl+A` (or `Cmd+A` on Mac) to select all, then `Ctrl+C` to copy!

---

### ✍️ `writeRecord(fileName, fingerprint, category, metadata)` - Write New Records

Stores a new file record on the blockchain.

**Parameters:**

- `fileName` (string): Name of the file
- `fingerprint` (string): SHA-256 hash of the file
- `category` (string): File category ("image", "video", "audio", "others")
- `metadata` (string, optional): Additional metadata to store

**Returns:**

- `string | null`: Transaction hash if successful, null if failed

**Example Usage:**

```typescript
import { writeRecord } from "./services/blockchain";

const txHash = await writeRecord(
  "example.jpg",
  "0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef", // SHA-256 hash
  "image",
  "photographer=John Doe;location=NYC" // Optional metadata
);

if (txHash) {
  console.log(`Transaction submitted: ${txHash}`);
} else {
  console.log("Failed to write record");
}
```

**📋 Sample cURL Command (click code block to select all):**

```bash
curl -X POST "https://rpc.stabilityprotocol.com/zkt/try-it-out" \
  -H "Content-Type: application/json" \
  -d '{
    "abi": ["function storeFile(string fileName, bytes32 fileHash, bytes data, string categoryStr)"],
    "to": "0xf79Fc7F6e7C36DCeCD04e603515315528BA9AC72",
    "method": "storeFile",
    "id": 1678886400001,
    "arguments": [
      "example.jpg",
      "0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef",
      "0x70686f746f6772617068657421646f653b6c6f636174696f6e3d4e5943",
      "image"
    ]
  }'
```

> 💡 **Tip:** Click inside the code block above, then use `Ctrl+A` (or `Cmd+A` on Mac) to select all, then `Ctrl+C` to copy!

> ⚠️ **Important:** If you get an error "File hash already stored", it means this hash is already on the blockchain! Please replace `0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef` with your actual file's SHA-256 hash or a different test hash.

---

## 📋 BlockchainRecord Interface

```typescript
interface BlockchainRecord {
  fileName: string; // Name of the file
  fileHash: string; // SHA-256 hash (0x prefixed)
  timestamp: number; // Unix timestamp
  category: string; // File category (image, video, audio, others)
  data?: string; // Optional metadata string
}
```

---

## 🗂️ Supported Categories

- **Image** (0)
- **Video** (1)
- **Audio** (2)
- **Others** (3)
