#!/bin/bash

echo -e "\e[31m __     ______  _   _  ____ \e[0m"
echo -e "\e[31m \ \   / / ___|| | | |/ ___|\e[0m"
echo -e "\e[31m  \ \ / /\___ \| |_| | |  _ \e[0m"
echo -e "\e[31m   \ V /  ___) |  _  | |_| |\e[0m"
echo -e "\e[31m    \_/  |____/|_| |_|\____|\e[0m"
echo ""
echo "      .--------."
echo "     / .------. \ "
echo "    / /        \ \ "
echo "    | |        | | "
echo "   _| |________| |_ "
echo " .' |_|        |_| '."
echo " '._____ ____ _____.'"
echo " |     .'____'.     |"
echo " '.__.'.'    '.'.__.'"
echo " '.__  | VSHG |  __.'"
echo " |   '.'.____.'.'   |"
echo " '.____'.____.'____.'"
echo " '.________________.'"
echo ""
echo   "##############################"
echo   "# A Standalone Addon for gpg #"
echo   "##############################"
echo ""
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
 
# checking for internet connection 

IPaddr=$(curl -s http://whatismyip.akamai.com/)
if [[ $IPaddr != "" ]]
then
echo ""
echo "You are connected to the Internet !"
echo "" 
else 
echo "##################################################"
echo "# !!! You are not connected to the Internet !!!  #"
echo "#------------------------------------------------#"
echo "#  running in offline mode ! some features might #"
echo "#  not work properly .                           #" 
echo "##################################################"
echo ""
internetcon="nope"
sleep 3
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

# checking for GPU resistance libraries 

echo "#########################################"
echo "# Checking for GPU resistance libraries #"
echo "#########################################"
echo ""
sleep 2 
if [ -d /etc/Argon2 ]
then
echo "Argon2 already installed and ready to use !"
sleep 1 
echo ""
else
echo "Installing Argon2"
sudo git clone https://github.com/P-H-C/phc-winner-argon2.git /etc/Argon2
cd /etc/Argon2
make 
fi 
cd /

# checking for secure-delete 

if ( sudo srm --help | grep -q "srm" ) 
then 
echo "srm already installed !"
echo ""
else 
sudo apt-get install secure-delete 
fi 

# checking for zip 

if ( sudo zip --help | grep -q "Info-ZIP" )
then 
echo "zip is already installed  !"
echo ""
else
sudo apt-get install zip 
fi 

# checking for rawstring file 

if [ -f /etc/VSHG/rawstring.txt ]
then 
sudo shred -n 15 -z -u /etc/VSHG/rawstring.txt
else 
echo "Nothing to remove !"
echo ""
fi
 
# checking for folder 

if [ -d /etc/VSHG ]
then 
echo "Folder in place !"
echo ""
else 
echo "creating folder"
echo ""
sudo mkdir /etc/VSHG
sudo mkdir /etc/VSHG/keydb

fi

# checking for key folder 

if [ -d /etc/VSHG/keydb ]
then 
echo "Keyfolder in place !"
echo ""
else 
echo "creating Keyfolder"
echo ""
sudo mkdir /etc/VSHG/keydb

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
tail=$( tail -1 $decryptyn2 )
if ( echo $tail | grep -q "VSHG_autodetect" );

then 
autodetect=$( echo $tail | sed -e 's/VSHG_autodetect://' );
autodetect1=$( cut -d ":" -f 1 <<< "$autodetect" ) 
autodetect2=$( cut -d ":" -f 2 <<< "$autodetect" ) 
autodetect3=$( cut -d ":" -f 3 <<< "$autodetect" )  

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

# GPU resistance ( Decryption )

echo "###############################################"
echo "# Initialising GPU resistance Countermeasures #"
echo "###############################################"
echo ""
gpuiterations=100
for ((i=gpuiterations; i>=0; i--))
do
gpuiterating=$( echo -n $finald | ./etc/Argon2/argon2 $dsalt -i -t 15 -p 16 -l 63 -m 12 -r )
finald=$gpuiterating
done 
 
final2=$( echo -n $gpuiterating | ./etc/Argon2/argon2 $dsalt -d -t 500 -p 16 -l 128 -m 12 -r  )

passwrd=$final2

# string splitting 

echo $passwrd > /etc/VSHG/final3.txt
finalcascade=$( fold -b128 /etc/VSHG/final3.txt )
echo ""
finalcascade2=$( echo $finalcascade | cut -d$' ' -f1 )
finalcascade3=$( echo $finalcascade | cut -d$' ' -f2 )

sudo shred -n 15 -z -u /etc/VSHG/final3.txt


echo $finalcascade3 | sudo gpg -o "$decryptyn2.tmp.original" -q --batch --passphrase-fd 0 --decrypt $decryptyn2  
echo $finalcascade2 | sudo gpg -o "$decryptyn2.original" -q --batch --passphrase-fd 0 --decrypt "$decryptyn2.tmp.original"

sudo shred -n 1 -z -u "$decryptyn2.tmp.original"

echo ""
echo "now decrypting " 
sudo bleachbit --clean bash.history --overwrite 
sleep 3

if [[ -f "$decryptyn2.original" ]]
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

echo ""
echo "######################"
echo "# Special thanks !!! #"
echo "######################"
echo ""
echo "#####################################################################"
echo "#                                                                   #"
echo "# Developed by : Richard R Matthews                                 #"
echo "#                                                                   #"
echo "# The great gpg project and its Developers : https://www.gnupg.org/ #"
echo "#                                                                   #"
echo "# The University of Luxembourg and it's strong Argon2 function      #"
echo "#                                                                   #"
echo "# The openssl Project and its Developers : https://www.openssl.org/ #"
echo "#                                                                   #"
echo "#####################################################################"

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
echo "useing keyfile "
echo ""

 # Use custom keyfile 

echo "Do you want to use a custom keyfile ?"
echo ""
echo -e "Note that it has to be a 512 bit brainpool curve\e[31m (brainpoolP512t1)\e[0m"
echo "(Y/N)"
read customekeyfileyesorno
if [[ $customekeyfileyesorno == *"Y"* ]]
then 
echo ""
echo "Useing custom keyfile "
echo "Please input it "
read customkeyfileinput 
customekeyfileinput2=$( echo "$customkeyfileinput" | tr -d "'" )
cusotomkeyfilehash=$( cat $customekeyfileinput2 | sha384sum )
cusotomkeyfilehash2=$( echo $cusotomkeyfilehash | tr -d - )
x=$cusotomkeyfilehash2

 # end " useing custom keyfile "  

 # not useing custom keyfile 

else 
echo "not useing custom keyfile "
echo ""

sleep 1
echo "What do you want to name the keyfile ?"
read keyfilename 

 # offline mode 
if [[ $internetcon == "nope" ]]
then 
echo ""
echo "! running in offline mode !"
echo ""
sudo openssl rand -base64 256 >> /etc/VSHG/keyfilerandomness.rand  
sudo openssl ecparam -genkey -rand /etc/VSHG/keyfilerandomness.rand -name brainpoolP512t1 -out /etc/VSHG/keydb/$keyfilename.vshgkey

else 
 
 # end offline mode 

rawkeyfile=$( wget -q -O /etc/VSHG/random_for_keyfile.txt https://www.random.org/cgi-bin/randbyte?nbytes=128&format=d )
sudo openssl ecparam -genkey -rand /etc/VSHG/random_for_keyfile.txt -name brainpoolP512t1 -out /etc/VSHG/keydb/$keyfilename.vshgkey
sudo shred -n 15 -z -u /etc/VSHG/random_for_keyfile.txt

fi 
echo ""
echo "! Please save the keyfile after encryption !"
echo ""

echo "The keyfile is located at /etc/VSHG/keydb/$keyfilename.vshgkey "
keyfilefingerprint=$( cat /etc/VSHG/keydb/$keyfilename.vshgkey | sha384sum )
keyfilefingerprint2=$( echo $keyfilefingerprint | tr -d - )
x=$keyfilefingerprint2

echo ""
fi 


# end of useing random generated keyfile 


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

# getting salt 

 #offline salt 

if [[ $internetcon == "nope" ]]
then 

echo ""
echo "! running in offline mode !"
echo ""
saltb64=$( sudo openssl rand -base64 13 );

else

echo ""
echo "getting salt"
Random=$( wget -q -O /etc/VSHG/randombytes.txt https://www.random.org/cgi-bin/randbyte?nbytes=12&format=d );
echo "got salt"
echo ""
salt=$( cat /etc/VSHG/randombytes.txt );
saltb64=$( echo $salt |  base64 );
sudo shred -n 15 -z -u /etc/VSHG/randombytes.txt
fi 

 # custom salt 

echo "Do you want to use a custom salt ( not recommanded ) "
echo "If you want , input it here or continue with ENTER"
blank="";
read customsalt
if [[ $customsalt == $blank ]];
then 
echo "Useing random salt $saltb64 "
else
saltb64=$customsalt
echo "Useing custom salt $saltb64"
fi

# finished getting salt 
echo ""
complete=$rawstring$saltb64 >> /etc/VSHG/complete.txt
sleep 2
echo ""
iterations=800
echo "How many iterations do you want to have ? ( default 800 ) or ENTER for default"
read it 
if [[ $it == $blank ]];
then 
echo "Useing default"
else 
iterations=$it
echo "useing $iterations iterations "

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

# GPU resistance ( Encryption )

echo "##############################################"
echo "# Initialising GPU resistance Countermesures #"
echo "##############################################"
echo ""
gpuiterations=100
final=$final
for ((i=gpuiterations; i>=0; i--))
do
gpuiterating=$( echo -n $final | ./etc/Argon2/argon2 $saltb64 -i -t 15 -p 16 -l 63 -m 12 -r );
final=$gpuiterating
done 


final2=$( echo -n $final | ./etc/Argon2/argon2 $saltb64 -d -t 500 -p 16 -l 128 -m 12 -r  )

# string splitting 

echo $final2 > /etc/VSHG/final3.txt
finalcascade=$( fold -b128 /etc/VSHG/final3.txt )
echo ""
finalcascade2=$( echo $finalcascade | cut -d$' ' -f1 )
finalcascade3=$( echo $finalcascade | cut -d$' ' -f2 )
sudo shred -n 15 -z -u /etc/VSHG/final3.txt


# loop finished 

sleep 2
echo "shreddering all critical files " 
sudo shred -n 15 -z -u /etc/VSHG/rawstring.txt
sudo shred -n 15 -z -u /etc/VSHG/complete.txt

# generator end 

# encryption 

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
sudo srm -r -f -l "$filetoenc2"
filetoenc2="$filetoenc2.zip"
fi

# file detection finished 

# encryption 2 

sudo echo $finalcascade2 | sudo gpg --batch --compress-algo 0 -q --passphrase-fd 0 -o "$filetoenc2.tmp.vshg" --s2k-mode 3 --s2k-count 65011712 --s2k-digest-algo sha512 --s2k-cipher-algo AES256 --symmetric --armor --cipher-algo AES256 -c "$filetoenc2" 

sudo echo $finalcascade3 | sudo gpg --batch --compress-algo 0 -q --passphrase-fd 0 -o "$filetoenc2.vshg" --s2k-mode 3 --s2k-count 65011712 --s2k-digest-algo sha512 --s2k-cipher-algo CAST5 --symmetric --armor --cipher-algo CAST5 --force-mdc -c "$filetoenc2.tmp.vshg" 

sudo shred -n 1 -z -u $filetoenc2.tmp.vshg &


echo "writeing autodetection log "

echo "VSHG_autodetect:$filetoenc:$iterations:$saltb64" >> "$filetoenc2.vshg"
echo ""
echo "successfully encrypted "
echo ""
sleep 3
history -c 
sudo bleachbit --clean bash.history --overwrite


if [[ $destorgfile == "Y" ]]
then 
sudo shred -f -n 3 -v -z -u $filetoenc2
sudo bleachbit --clean bash.history --overwrite 
echo ""
echo "Shreddered original file "
else 
echo ""
echo "########"
echo "# Done #"
echo "########"
fi 
echo ""
echo "######################"
echo "# Special thanks !!! #"
echo "######################"
echo ""
echo "########################################################################"
echo "#                                                                      #"
echo "# Developed by : Richard R Matthews : RichardR.Matthews@protonmail.com #"
echo "#                                                                      #"
echo "# The great gpg project and its Developers : https://www.gnupg.org/    #"
echo "#                                                                      #"
echo "# The University of Luxembourg and it's strong Argon2 function         #"
echo "#                                                                      #"
echo "# The openssl Project and its Developers : https://www.openssl.org/    #"
echo "#                                                                      #"
echo "# Big thank´s to random.org for providing the entropy                  #"
echo "#                                                                      #"
echo "########################################################################"
