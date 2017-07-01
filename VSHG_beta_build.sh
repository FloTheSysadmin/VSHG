#!/bin/bash
echo -e "\e[31m##############################\e[0m"
echo -e "\e[31m# Very secure hash generator #\e[0m"
echo -e "\e[31m##############################\e[0m"
echo ""
echo   "##############################"
echo   "# A Standalone Addon for gpg #"
echo   "##############################"
echo ""
echo "This tool allows you to use a very weak passwort and still get very strong encryption key at the end "
echo "thanks for using my VSHG :)"
sleep 2 
# checking for root 
if whoami | grep -q "root"
then 
echo ""
echo "you are root --> Everything ok "
echo ""
sleep 2
else 
echo ""
echo "you should be root "
echo ""
sleep 2 
exit 1 
fi 

# gpg check 
echo "################################"
echo "# Checking if gpg is installed #"
echo "################################"
echo ""
if ( sudo gpg --help | grep -q "Syntax:" )
then 
echo ""
echo "GPG already installed :)"
echo ""
sleep 1
else
echo "installing GPG"
sleep 2
echo "" 
sudo apt-get install gpg 
sudo apt-get install gnupg

fi

# checking for rawstring file 

if [ -f /etc/VSHG/rawstring.txt ]
then 
sudo shred -n 15 -z -u /etc/VSHG/rawstring.txt
else 
echo "Nothing to remove "
echo ""
fi
 
# checking for folder 

if [ -d /etc/VSHG ]
then 
echo "Folder in place"
echo ""
else 
echo "creating folder"
sudo mkdir /etc/VSHG
fi
echo "Do you want to run VSHG in encrypt or in decrypt mode ? ( E/D )"
read eord 

# module decryption 

if [[ $eord == "D" ]];

then 

# autodetection 

echo "runnig in decrypt mode ."
echo ""
echo "Which file do you want to decrypt ? "
read decryptyn
decryptyn2=$( echo "$decryptyn" | tr -d "'");
decryptyn3=$( echo "$decryptyn2" | sed -e 's/.vshg//' );

if ( echo "$decryptyn3" | grep ".zip" ) 
then 
echo ""
echo "zip file"
echo ""
decryptyn3=$( echo "$decryptyn3" | sed -e 's/.zip//' );
fi 

echo ""
echo "Trying to autodetect the salt and iterations"
echo ""
if ( ls -a $decryptyn2 | grep -q $decryptyn3 );

then 
autodetect=$( grep -rnw $decryptyn2 -e "'$decryptyn3'" );
autodetect1=$( cut -d ":" -f 2 <<< "$autodetect" ) 
autodetect2=$( cut -d ":" -f 3 <<< "$autodetect" ) 
autodetect3=$( cut -d ":" -f 4 <<< "$autodetect" )  

# manual detection 
 
if [[ $autodetect1 == "" ]]
then 
echo ""
echo "##############################################"
echo "# Could not autodetect the salt / iterations #"
echo "##############################################"
echo ""

 # Use keyfile is autodetection fails 

echo "Do you want to use a keyfile for the decryption (Y/N) "
read decryptusekeyfile 
if [[ $decryptusekeyfile == *"Y"* ]]
then 
echo ""
echo "Please drop the key file here "
read keyfileis 
keyfileis2=$( echo "$keyfileis" | tr -d "'" )
keyfilehashdecrypt=$( cat "$keyfileis2" | sha384sum )
keyfilehashdecrypt2=$( echo "$keyfilehashdecrypt" | tr -d - )
passwrd=$keyfilehashdecrypt2
else 

echo "please input a password " 
stty -echo
read -p "Password :" passwrd; echo
stty echo  
fi 
echo "whith what salt ? "
read dsalt
echo "How many iterations ? "
read dit  

completed=$passwrd$dsalt
echo "the string to hash is <password>:$dsalt"
# automatic detection 2 

else 
echo " Autodetected file $autodetect1"
echo " Autodetected iterations $autodetect2"
echo " Autodetected salt $autodetect3"
echo ""
 # use keyfile in decryption

echo "Do you want to use a keyfile for the decryption (Y/N) "
read decryptusekeyfile 
if [[ $decryptusekeyfile == *"Y"* ]]
then 
echo ""
echo "Please drop the key file here "
read keyfileis 
keyfileis2=$( echo "$keyfileis" | tr -d "'" )
keyfilehashdecrypt=$( cat "$keyfileis2" | sha384sum )
keyfilehashdecrypt2=$( echo "$keyfilehashdecrypt" | tr -d - )
passwrd=$keyfilehashdecrypt2
else 

 # use normal password in decryption 

echo "Please input a password "

stty -echo
read -p "Password :" passwrd; echo
stty echo  
fi 

dsalt=$autodetect3
dit=$autodetect2
completed=$passwrd$dsalt
echo "the string to hash is <password>:$dsalt"
fi
else 
echo ""
echo "could not match any iterations / a salt" 
fi 

# end 

sleep 2
 
# decryption loop 

iterated1=$( echo -n $completed | sha384sum ); 
iteratedd2=$( echo "$iterated1" | tr -d - );
echo ""
echo "#########################"
echo "# Hashing ! please wait #"
echo "#########################"
echo ""
for ((i=dit; i>=0; i--))
do

runningitd=$( echo -n $iteratedd2 | sha384sum )
iteratedd2=$runningitd
finald=$( echo "$iteratedd2" | tr -d - );


done

passwrd=$finald
echo "The final iterated hash is $dit:$dsalt:$passwrd"
echo $passwrd | sudo gpg -o "$decryptyn2.oreginal" -q --batch --passphrase-fd 0 --decrypt $decryptyn2  
echo "now decrypting " 
sudo bleachbit --clean bash.history --overwrite 
sleep 3

if [[ -f "$decryptyn2.oreginal" ]]
then 
echo ""
echo "#################################"
echo "# file successfully decrypted ! #"
echo "#################################"
history -c 
else 
echo ""
echo "##################################################"
echo "# !!! there was an error decrypting the file !!! #"
echo "##################################################"
history -c 
fi
exit 1

# decryption end 

# generator 
else 
echo ""
echo "###########################"
echo "# running in encrypt mode #"
echo "###########################"
fi
sleep 2
echo ""

# Use a keyfile 

echo "Do you want to use a keyfile ? (Y/N) "
read usekeyfile
if [[ $usekeyfile == *"Y"* ]]
then 
echo ""
echo "using keyfile "
echo ""
sleep 1
echo "What do you want to name the keyfile ?"
read keyfilename 
rawkeyfile=$( wget -q -O /etc/VSHG/random_for_keyfile.txt https://www.random.org/cgi-bin/randbyte?nbytes=128&format=d )
sudo openssl ecparam -genkey -rand /etc/VSHG/random_for_keyfile.txt -name brainpoolP512t1 -out /etc/VSHG/$keyfilename.vshgkey
echo ""
echo "! Please save the keyfile after encryption !"
echo ""
sudo shred -n 15 -z -u /etc/VSHG/random_for_keyfile.txt
echo "The keyfile is located at /etc/VSHG/$keyfilename.vshgkey "
keyfilefingerprint=$( cat /etc/VSHG/$keyfilename.vshgkey | sha384sum)
keyfilefingerprint2=$( echo $keyfilefingerprint | tr -d - )
x=$keyfilefingerprint2
echo "debug $x "

# Use normal passphrase 

else 

if [[ usekeyfile == *"Y"* ]]
then 
echo ""
else 

 
echo "please input your password to be hashed "
echo ""
stty -echo
read -p "Password :" x; echo
stty echo 
echo ""
echo "please repeat the password "
echo ""
stty -echo
read -p "Password :" x2; echo
stty echo

if [[ $x == $x2 ]]
then 
echo ""
echo "Passwords match !"
echo ""
sleep 2
else 
echo ""
echo "passwords dont match :( "
echo ""
sleep 2
echo "exiting"
echo ""
sleep 1
exit 1 
fi 
fi
fi


echo "$x" >> /etc/VSHG/rawstring.txt
rawstring=$(cat /etc/VSHG/rawstring.txt)
echo ""
echo "getting salt"
Random=$( wget -q -O /etc/VSHG/randombytes.txt https://www.random.org/cgi-bin/randbyte?nbytes=12&format=d );
echo "got salt"
echo ""
salt=$( cat /etc/VSHG/randombytes.txt );
saltb64=$( echo $salt |  base64 );
echo "Do you want to use a custom salt ( not recommanded ) "
echo "If you want input it here or continue with ENTER"
blank="";
read customsalt
if [[ $customsalt == $blank ]];
then 
echo "Using default salt $saltb64 "
else
saltb64=$customsalt
echo "Using custom salt $saltb64"
fi
complete=$rawstring$saltb64 >> /etc/VSHG/complete.txt
sleep 2
echo ""
iterations=500
echo "How many iterations do you want to have ? ( default 500 ) or ENTER for default "
read it 
if [[ $it == $blank ]];
then 
echo "Using default"
else 
iterations=$it
echo "using $iterations iterations "


# generator 2 
 
fi

iterated=$( echo -n "$complete" | sha384sum ); 
iterated2=$( echo "$iterated" | tr -d - );

# Iteration loop 

echo ""
echo "#########################"
echo "# Hashing ! please wait #"
echo "#########################"
echo ""
for ((i=iterations; i>=0; i--))
do
runningit=$( echo -n $iterated2 | sha384sum )
iterated2=$runningit
final=$( echo "$runningit" | tr -d - );
done 
# loop finished 

sleep 2
echo "shreddering all critical files " 
sudo shred -n 15 -z -u /etc/VSHG/randombytes.txt
sudo shred -n 15 -z -u /etc/VSHG/rawstring.txt
sudo shred -n 15 -z -u /etc/VSHG/complete.txt
if [[ $secit == "Y" ]]
then 
echo ""
echo "Format = salt:hash "
echo ""
echo "Iterations are treated as a secret value "
echo ""
echo " final iterated hash =  $saltb64:$final"
else 
echo ""
echo "Format = iterations:salt:hash "
echo ""
echo " final iterated hash =  $iterations:$saltb64:$final"
fi

# generator end 

# encryption 

echo "" 
echo "Session key is $final"
echo ""
echo ""
echo "Destroy original file after encryption ? ( Y/N )"
read destorgfile 
echo "Which file do you want to encrypt now ?"
echo ""
read filetoenc
filetoenc2=$( echo "$filetoenc" | tr -d "'");

# checking if file is a directory 

if [[ -d $filetoenc2 ]];
then 
echo "Folder"
echo "Zip-ing"
echo ""
sleep 2
echo ""
sudo zip -r "$filetoenc2.zip" "$filetoenc2" 
filetoenc2="$filetoenc2.zip"
fi

# file detection finished 

# encryption 2 

sudo echo $final | sudo gpg --batch -q --passphrase-fd 0 -o "$filetoenc2.vshg" --symmetric --armor --cipher-algo AES256 -c "$filetoenc2" 
echo "writeing autodetection log "
echo "$filetoenc:$iterations:$saltb64" >> "$filetoenc2.vshg"
echo ""
echo "successfully encrypted "
echo ""
sleep 3
history -c 
sudo bleachbit --clean bash.history --overwrite
if [[ $destorgfile == "Y" ]]
then 
sudo shred -f -n 15 -v -z -u $filetoenc2
sudo bleachbit --clean bash.history --overwrite 
echo ""
echo "Shreddered original file "
else 
echo "Done"
fi 
