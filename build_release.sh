#!/bin/bash

#### Made by Vamist for TC builds

## VARS
SOUND_FOLDER="TFlippy_TerritoryControl_Sounds"


## FUNCTIONS
delete_thing () {
     echo "Deleting $1"
     rm -rf $1
}



## START

echo "\# Clearing files"

delete_thing "TerritoryControl_Autumn_Dev.zip"
delete_thing "README.md"
delete_thing "TFlippy_TerritoryControl_Winter_Dev" # TODO: Toggle 





# TODO: Allow us to change v130
echo "# Renaming dev to v130"

for file in *
do
    if [[ ${file: -4} == "_Dev" ]]; then
        echo $file
        new_name=${file::-3}
        new_name=$new_name"v130"
        mv $file $new_name
    fi
done





echo "# Moving .ogg to a new folder"

mkdir $SOUND_FOLDER 2>/dev/null

list="$(find . -name '*.ogg')"

for file in $list
do
    mv $file $SOUND_FOLDER/ 2>/dev/null
    rm -rf $file
done


echo "# Done!"
