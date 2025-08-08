// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FileHashStorage {
    enum Category { Image, Video, Audio, Other }

    struct FileRecord {
        address owner;
        string fileName;
        bytes32 fileHash;
        uint timestamp;
        bytes data;
        Category category;
    }

    struct ModifiedFileRecord{
        bytes32 originalFileHash;
        bytes32 fileHash;
        uint timestamp;
        bytes data;
    }
    mapping(bytes32 => ModifiedFileRecord) public modifiedFiles;
    mapping(bytes32 => bytes32[]) public modifiedFilesReferences;
    mapping(bytes32 => FileRecord) public files;
    bytes32[] private fileOrder;

    uint public totalFilesUploaded;
    uint public totalImages;
    uint public totalVideos;
    uint public totalAudios;
    uint public totalOthers;

    event ReferenceFileStored(
        address indexed owner,
        bytes32 fileHash,
        bytes32 originalfileHash,
        uint timestamp,
        bytes data
    );

    
    event FileStored(
        address indexed owner,
        string fileName,
        bytes32 fileHash,
        uint timestamp,
        bytes data,
        string category
    );

    
    function storeReferenceFile(
        bytes32 fileHash,
        bytes32 originalfileHash,
        bytes calldata data
     
    ) public {
        require(fileHash != 0, "Invalid file hash");
        require(files[originalfileHash].fileHash != 0, "Original hash does not exist");
        require(modifiedFiles[fileHash].fileHash == 0, "Reference File hash already stored");
        modifiedFiles[fileHash] = ModifiedFileRecord(

            originalfileHash,
            fileHash,
            block.timestamp,
            data
        );
        modifiedFilesReferences[originalfileHash].push(fileHash);
        emit ReferenceFileStored(msg.sender,  fileHash,originalfileHash, block.timestamp, data);
    }



    function storeFile(
        string memory fileName,
        bytes32 fileHash,
        bytes calldata data,
        string memory categoryStr,
        bool
    ) public {
        require(fileHash != 0, "Invalid file hash");
        require(bytes(fileName).length > 0, "Invalid file name");
        require(bytes(fileName).length <= 256, "File name too long");
        require(files[fileHash].fileHash == 0, "File hash already stored");

        Category category = _parseCategory(categoryStr);

        files[fileHash] = FileRecord(
            msg.sender,
            fileName,
            fileHash,
            block.timestamp,
            data,
            category
        );

        fileOrder.push(fileHash);

        totalFilesUploaded++;
        if (category == Category.Image) totalImages++;
        else if (category == Category.Video) totalVideos++;
        else if (category == Category.Audio) totalAudios++;
        else totalOthers++;

        emit FileStored(msg.sender, fileName, fileHash, block.timestamp, data, categoryStr);
    }

    function getFile(bytes32 fileHash) public view returns(FileRecord memory,bool,ModifiedFileRecord memory referenceRecord) {
        require(files[fileHash].fileHash != 0 || modifiedFiles[fileHash].fileHash != 0 , "File hash not found");
        if(files[fileHash].fileHash != 0 ){
        return (files[fileHash],false, referenceRecord);
        }
        if(modifiedFiles[fileHash].fileHash != 0){
         return (files[modifiedFiles[fileHash].originalFileHash],true, modifiedFiles[fileHash]);
        }

    }

    function getFilesByCategory(
        string memory categoryStr,
        uint page,
        uint itemsPerPage
    ) public view returns (FileRecord[] memory) {
        require(itemsPerPage > 0, "Items per page must be > 0");
        require(page > 0, "Page must be > 0");

        bytes32 cat = keccak256(abi.encodePacked(categoryStr));
        bool matchCategory = (
            cat == keccak256("image") ||
            cat == keccak256("video") ||
            cat == keccak256("audio") || 
            cat == keccak256("other") 
        );

        Category category = _parseCategory(categoryStr);

        FileRecord[] memory tempResults = new FileRecord[](itemsPerPage);
        uint found = 0;
        uint itemsToSkip = (page - 1) * itemsPerPage;

        for (uint i = fileOrder.length; i > 0; i--) {
            FileRecord storage record = files[fileOrder[i - 1]];

            if (!matchCategory || record.category == category) {
                if (itemsToSkip > 0) {
                    itemsToSkip--;
                    continue;
                }
                if (found < itemsPerPage) {
                    tempResults[found] = record;
                    found++;
                } else {
                    break;
                }
            }
        }

        FileRecord[] memory results = new FileRecord[](found);
        for (uint j = 0; j < found; j++) {
            results[j] = tempResults[j];
        }

        return results;
    }

     function getFilesByCategory_v2(
        string memory categoryStr,
        uint page,
        uint itemsPerPage
    ) public view returns ( FileRecord memory fr1,FileRecord memory fr2,FileRecord memory fr3,FileRecord memory fr4,FileRecord memory fr5) {
        require(itemsPerPage > 0, "Items per page must be > 0");
        require(page > 0, "Page must be > 0");

        bytes32 cat = keccak256(abi.encodePacked(categoryStr));
        bool matchCategory = (
            cat == keccak256("image") ||
            cat == keccak256("video") ||
            cat == keccak256("audio") || 
            cat == keccak256("other") 
        );

        Category category = _parseCategory(categoryStr);

        FileRecord[] memory tempResults = new FileRecord[](itemsPerPage);
        uint found = 0;
        uint itemsToSkip = (page - 1) * itemsPerPage;

        for (uint i = fileOrder.length; i > 0; i--) {
            FileRecord storage record = files[fileOrder[i - 1]];

            if (!matchCategory || record.category == category) {
                if (itemsToSkip > 0) {
                    itemsToSkip--;
                    continue;
                }
                if (found < itemsPerPage) {
                    tempResults[found] = record;
                    found++;
                } else {
                    break;
                }
            }
        }

        FileRecord[] memory results = new FileRecord[](found);
        for (uint j = 0; j < found; j++) {
            results[j] = tempResults[j];
        }

        return ( tempResults[0],tempResults[1],tempResults[2],tempResults[3],tempResults[4] );
    }

    function _parseCategory(string memory categoryStr) internal pure returns (Category) {
        bytes32 cat = keccak256(abi.encodePacked(categoryStr));
        if (cat == keccak256("image")) return Category.Image;
        if (cat == keccak256("video")) return Category.Video;
        if (cat == keccak256("audio")) return Category.Audio;
        return Category.Other;
    }
}
