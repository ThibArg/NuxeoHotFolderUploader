NuxeoHotFolderShellScript
=========================

The script get all the files in a folder and create documents (`File`, `Picture` or `Video`) in Nuxeo.

It runs on Linux and Mac OS.

###Usage
_Do not forget to make the .sh executable (for example, chmod +x /the/script)_ 
```
/path/to/the/script.sh "/path/to/the/hotfolder"
```
Or
```
/path/to/the/script.sh "/path/to/the/hotfolder" "/path/to/the/hotfolder-backup"
```
Parameters:

* $1 is the path to the ot folder
* $2 is optionnal: Path to a backup folder

Once a file has been sent:

* If `$2`was passed, the file is moved to this folder
* Else, the file is _permanently_ deleted (`rm`)
  * __WARNING__: The script does not check errors returned by `curl`. So, whatever happens, the file will be deleted (see "Room for enhancement").


###Main principles
The script gets the kind (Nuxeo document type:  `File`, `Picture` or `Video`) of the binary file, based on its mime-type. It adds some adjustement when our testing showed that a `File`document was created for a `raw`picture for example.

What you may need to change:

* Variables at the top  of the script:
  * `SERVER_BASE_URL`: Address of the server. Including the context path (/nuxeo)
  * Credentials: `USER_LOGIN`and `USER_PWD`
  * `NUXEO_DESTINATION_URL`:
    * The destination path, on nuxeo server.
    * *IMPORTANT*: Make sure the user (`USER_LOGIN`/`USER_PWD`) has the right to create document at this path
  * `LOG_PATH`: This one is set to save the log in the $HOME folder of the current user. Something you may want to change.
* Mime-type detection: Add your specific types, Nuxeo document types, etc.

Also, make sure the Linux/Mac OS user running the script has enough right to read/write the hot folder.

Once you are happy with the script, just add it to your `crontab` (or similar)

###Room for enhancement
The script is quite simple. It was built for a quick Proof of Concept, and deserves to be enhanced. For example:

* Better error handling:
  * If an error occurs with `curl`, do not delete the file, move it somewhere else (when `$2`is not passed)
  * If an error occurs, report it in the log
* . . .



###License: MIT
"Do whatever You Want With the Source Code"


### About Nuxeo

Nuxeo provides a modular, extensible Java-based [open source software platform for enterprise content management](http://www.nuxeo.com/en/products/ep) and packaged applications for [document management](http://www.nuxeo.com/en/products/document-management), [digital asset management](http://www.nuxeo.com/en/products/dam) and [case management](http://www.nuxeo.com/en/products/case-management). Designed by developers for developers, the Nuxeo platform offers a modern architecture, a powerful plug-in model and extensive packaging capabilities for building content applications.

More information on: <http://www.nuxeo.com/>

