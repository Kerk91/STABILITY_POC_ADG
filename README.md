# STABILITY_POC - File Authentication on the Global Trust Network

Allows users to securely verify and manage file authenticity using blockchain technology through the Global Trust Network (GTN).

---

## 🌐 Live Demo

Try the sample application at **[https://stblchain.io/](https://stblchain.io/)** to see the blockchain file verification system in action!

---

## 🔧 Configuration

Head over to **[https://portal.stabilityprotocol.com/](https://portal.stabilityprotocol.com/)** to generate your API key.

Your API key will look something like `whay3333a6u2`.

For this example we will use the following ZKT v2 to communicate with the Network.
For more information please head over to **[https://docs.stabilityprotocol.com/developers/zkt](https://docs.stabilityprotocol.com/developers/zkt)** to learn more about the parameters of the endpoint (eg. abi,to,method,id,arguments).

---

## Direct Enquiry/Update to the Network

Sample Endpoint: `https://rpc.stabilityprotocol.com/zkt/[Your API Key]`

### 🔍 `verifyFile(fingerprint)` - Verify File Records

Checks if a file fingerprint exists on the blockchain and retrieves its metadata.

| Parameter     | Type   | Description                                          | Sample Value                                                         |
| ------------- | ------ | ---------------------------------------------------- | -------------------------------------------------------------------- |
| `fingerprint` | string | SHA-256 hash of the file (with or without 0x prefix) | `0x8687fa37d02e6d2ce4a27dcd5cb36caf0fac1e26c9879df46a00e4d009c1dab1` |

**Returns:** `BlockchainRecord | null` - File record if found, null if not found

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

---

### ✍️ `writeRecord(fileName, fingerprint, category, metadata)` - Write New Records

Stores a new file record on the blockchain.

| Parameter     | Type              | Description                  | Sample Value                                                         |
| ------------- | ----------------- | ---------------------------- | -------------------------------------------------------------------- |
| `fileName`    | string            | Name of the file             | `example.jpg`                                                        |
| `fingerprint` | string            | SHA-256 hash of the file     | `0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef` |
| `category`    | string            | File category                | `image`                                                              |
| `metadata`    | string (optional) | Additional metadata to store | `photographer=John Doe;location=NYC`                                 |

**Returns:** `string | null` - Transaction hash if successful, null if failed

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

> ⚠️ **Important:** If you get an error "File hash already stored", it means this hash is already on the blockchain! Please replace `0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef` with your actual file's SHA-256 hash or a different test hash.

---

## 📋 BlockchainRecord Interface

```typescript
interface BlockchainRecord {
  fileName: string; // Name of the file
  fileHash: string; // SHA-256 hash (0x prefixed bytes32)
  timestamp: number; // Unix timestamp
  category: string; // File category (image 0 , video 1, audio 2, others 3)
  data?: string; // Optional metadata string
}
```

---

## Environment/Data Implementation

`contract/FileHash.sol`.

---

## Reference Implementation

`services/blockchain.ts`.
