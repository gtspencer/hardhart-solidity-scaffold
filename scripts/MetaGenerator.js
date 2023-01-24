const fs = require('fs')

const pathToFiles = 'E:\\NFTProject\\redo'
const newPathToFiles = 'E:\\NFTProject\\metadata\\'
const files = fs.readdirSync(pathToFiles)

async function doTHis() {
    for (const file of files) {
        if (file.endsWith('.mov')) {
            // var splitarray = file.split("_")

            // var paddedNumber = splitarray[0]
            var paddedNumber = file;
            // rename file
            /*fs.rename(pathToFiles + "\\" + file, pathToFiles + "\\" + paddedNumber + ".png", function(err, result) {
                if(err) console.log('error', err);
            })*/

            // generate metadata json file
            var intNum = parseInt(paddedNumber)
            var metaDict = {
                "animation_url": "ipfs://bafybeicqoikhf7jgzp5njvzqgbgx7yv2kxn27q6dvvbshedkqf7awnd5zu/" + intNum + ".mov",
                "description": "Whereis22NFT will give holders exclusive access to Michael Rainey Jr. such as real world and digital experiences.  This utility filled project will give everyone the chance to have unique interactions and chances to grow within the space.",
                "name": "WHEREIS22 #" + intNum,
                "attributes":[
                    {
                        "trait_type" : "Number",
                        "value" : intNum.toString()
                    }
                ],
                "image": "ipfs://bafybeicvklufstq3oaughevuhvwxoytpifsnoabzoxqtlkfq44xi7bueam/" + intNum + ".PNG"
            }

            var dictString = JSON.stringify(metaDict)
            // solidity doesn't prepend with 0's, so name it just the number.json
            await fs.writeFile(newPathToFiles + intNum + ".json", dictString, function(err, result) {
                if(err) console.log('error', err);
            })
            console.log("done with " + intNum)
        }
    }
}

doTHis();