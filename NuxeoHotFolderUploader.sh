#!/bin/bash
SERVER_BASE_URL=http://localhost:8080/nuxeo
USER_LOGIN=Administrator
USER_PWD=Administrator
# This folder, or workspace, or container *must*:
#	- Exists
#	- Have ACL which allows USER_LOGIN to create document
NUXEO_DESTINATION_URL=$SERVER_BASE_URL/api/v1/path/default-domain/workspaces/hot-folder-import


COPY_DEST_FOLDER=""

function watch_folder {

# Don't spend time on empty folders
if [ "$(ls -A $1)" ]; then

  cd "$1"
  for file in "$1"/*; do

# Ignore invisible file, or system which adds /* for empty folders
  if [[ $file != .* && $file != "*" && $file != "$1/*" ]]; then

    nuxeo_doc_type="File"
    mime_type=`file --mime-type -b "$file"`
    case "$mime_type" in
      image/*) 
        nuxeo_doc_type="Picture";;
      
      video/*)
        nuxeo_doc_type="Video";;
        
      *)
          case $file in
          *.mov)
            nuxeo_doc_type="Video";;
          *.ORF)
            nuxeo_doc_type="Picture";;
          *.xmp)
            nuxeo_doc_type="Picture";;
          *)
            nuxeo_doc_type="File";;
        esac
    esac
  
    send_to_nuxeo "$file" "$nuxeo_doc_type"
  
  fi

  done

fi
}

function send_to_nuxeo {
    file_full_path=$1
    doc_type=$2
    filename="${file_full_path##*/}"
    filename_clean=${filename// /_}
  
    echo "Sending file $filename, type $doc_type"
    curl -H "X-Batch-Id: $filename_clean" -H "X-File-Idx:0" -H "X-File-Name:$filename" -F file=@"$file_full_path" -u "${USER_LOGIN}":"${USER_PWD}" "${SERVER_BASE_URL}/api/v1/automation/batch/upload"
    
    #echo ""
    #echo "CHECKING THE BATCH"
    #curl -u "${USER_LOGIN}":"${USER_PWD}" "${SERVER_BASE_URL}/api/v1/automation/batch/files/$filename_clean"
  
    echo "Creating a $doc_type document"
    curl -X POST -H "Content-Type: application/json" -u "${USER_LOGIN}":"${USER_PWD}" -d "{ \"entity-type\": \"document\", \"name\":\"${filename_clean}\", \"type\": \"${doc_type}\", \"properties\" : { \"dc:title\":\"${filename}\",\"file:content\": {\"upload-batch\":\"${filename_clean}\",\"upload-fileId\":\"0\"}}}" "${NUXEO_DESTINATION_URL}"
  
    if [ -n "$COPY_DEST_FOLDER" ]; then
      mv "$filename" "$COPY_DEST_FOLDER/$filename"
    else
      rm "$filename"
    fi
}

function print_usage {
  echo "Usage: upload_files.sh <folder> <optionnal copy folder>"
  echo "    If <optionnal copy folder> is used, files are moved to"
  echo "    this folder instead of being deleted"
  echo "    (Mainly used during development/debug.)"
}


if [ -d "$1" ]
then 
  if [ -n "$2" ]; then
    COPY_DEST_FOLDER="$2"
  fi
  watch_folder "$1"
else
  echo "Error: folder doesn't exist"
  print_usage
  exit 1
fi
