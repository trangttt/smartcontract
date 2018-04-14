var fs = require("fs");
var path = require("path");
var util = require("util");
var createKeccakHash = require('keccak');


OUTFILE_FORMAT = `
var addrList = [];
var tokenList = [];

%s

module.exports = {
    addrList: addrList,
    tokenList: tokenList
};`


LIST_FORMAT = `
addrList.push("%s");
tokenList.push("%s");
`

OUTPUT_FOLDER = `output`
INPUT_FOLDER = `input`
DEFAULT_DATA = `./app/data`


/**
 * Checks if the given string is an address
 *
 * @method isAddress
 * @param {String} address the given HEX adress
 * @return {Boolean}
 */
var isAddress = function (address) {
    if (!/^(0x)?[0-9a-f]{40}$/i.test(address)) {
        // check if it has the basic requirements of an address
        return false;
    } else if (/^(0x)?[0-9a-f]{40}$/.test(address) || /^(0x)?[0-9A-F]{40}$/.test(address)) {
        // If it's all small caps or all all caps, return true
        return true;
    } else {
        // Otherwise check each case
        return isChecksumAddress(address);
    }
};

/**
 * Checks if the given string is a checksummed address
 * WARN: address like 0x111111111111111111111111111111111111111111 still pass this test.!!!!!
 *
 * @method isChecksumAddress
 * @param {String} address the given HEX adress
 * @return {Boolean}
 */
function isChecksumAddress (address) {
    var origin = address
    address = address.toLowerCase().replace('0x', '')
    var hash = createKeccakHash('keccak256').update(address).digest('hex')
    var ret = '0x'

    for (var i = 0; i < address.length; i++) {
        if (parseInt(hash[i], 16) >= 8) {
            ret += address[i].toUpperCase()
        } else {
            ret += address[i]
        }
    }
    return ret ===  origin
}

/*
 * Form js file path from data path
 *
 * @method formName
 * @param {String} full path to data file
 * @return {String} full path to js file
 */
function formName(inFile){
    ext = path.extname(inFile);
    basename = path.basename(inFile, ext);
    return basename + ".js";
}


/**
 *  - Iterate over a folder
 *  - Extract addresses and number of tokens
 *  - Write dataxxx.js file, accordingly 
 *
 * @method processFolder
 * @param {String} full path to the folder
 */
function processFolder(folderPath){
   var contents
   inFolder = path.join(folderPath, INPUT_FOLDER)
   outFolder = path.join(folderPath, OUTPUT_FOLDER)

   try {
        contents = fs.readdirSync(inFolder, 'utf8');
        for (var i = 0; i < contents.length; i++){
            console.log("File ", contents[i])
            
            addresses = readFile(path.join(inFolder, contents[i]))
            if (addresses !== null)
                writeFile(addresses, path.join(outFolder, formName(contents[i])));
        }
   } catch (err){
        // in case of error, early exit
        console.log("Cannot open folder", err)
        return
   }
}


/**
 * Read a file and print out array of Ethereum addresses.
 * It skips incorrect Ethereum addresses and token number less than 0
 *
 * @method readFile
 * @param {String} path to the file
 */
function readFile(filePath) {
    var contents
    try {
        contents = fs.readFileSync(filePath, 'utf8');
    } catch (err){
        // in case of error, early exit
        console.log("Cannot open file", err)
        return null
    }

    var lines = contents.split("\n");
    var addresses = new Array()

    for ( var i=0; i < lines.length; i++){
        // skip the last empty line
        if ("" !== lines[i].trim()) {
            var isError = true;
            var raw = lines[i].replace(' ', '')
            var parts = raw.split(",")

            // each line must have both address and token number
            if (parts.length == 2){
                var address = parts[0].trim()
                var tokenNumber = parseInt(parts[1])

                // only keep non-negative token and valid address
                if (tokenNumber > 0 && isAddress(address)) {
                    isError = false;
                    addresses.push({"address": address,
                                    "token": tokenNumber})
                }
            }
            // print out error line
            if (isError) {
                console.log("[ERROR]", lines[i]);
            }
        }
    }

    // console.log(addresses)
    return addresses

}

/* 
 *  Get an array of 
 *  @method writeFile
 *  @param {array} array of object of type {address: xx, token: xx} 
 *  @param {filePath} name of output file
 */
function writeFile(addresses, filePath){
    // prepare content
    content = "";
    for(var i=0; i < addresses.length; i++){
        content +=  util.format(LIST_FORMAT, addresses[i].address, addresses[i].token);
    }

    content = util.format(OUTFILE_FORMAT, content);

    try {
        fs.writeFileSync(filePath, content, 'utf8');
    } catch (err){
        console.log("Cannot write file", err)
        return
    } 
}

if (require.main === module) {
    // folder from cmdline or default
    folder = process.argv.length == 3 ? process.argv[2] : DEFAULT_DATA
    processFolder(folder);
}

module.exports = {
    readFile,
    processFolder,
    writeFile,
}