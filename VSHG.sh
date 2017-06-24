#!/bin/bash
echo "##############################"
echo "# Very secure hash generator #"
echo "##############################"
echo ""
echo   "###############################"
echo   "#  A Standalone Addon for gpg #"
echo  " ###############################"
echo ""
echo "This tool allows you to use a super weak passwort and still get an exteramly stong string in the end "
echo ""
echo "thanks for using my VSHG :)"
sleep 2 
# checking for root 
if whoami | grep -q "root"
then 
echo ""
echo "you are root --> Everything ok "
else 
echo ""
echo "you should be root "
echo ""
sleep 2 
exit 1 
fi 
# checking for test file 
if [ -f /home/flo/Desktop/random_stuff/test.txt ]
then 
sudo shred -n 15 -z -u /home/flo/Desktop/random_stuff/test.txt
else 
echo "Nothing to remove "
fi 
# checking for folder 
if [ -d /etc/VSHG ]
then 
echo "Folder in place"
else 
echo "creating folder"
sudo mkdir /etc/VSHG
fi
echo "Do you want to run VSHG in encrypt or in decrypt mode ? ( E/D )"
read eord 

#module decryption 

if [[ $eord == "D" ]];

then 
echo "runnig in decrypt mode ."
echo ""
echo "Which file do you want to decrypt ? "
read decryptyn
decryptyn2=$( echo "$decryptyn" | tr -d "'");
echo "Trying to autodetect the salt and iterations"
fileyn=$( echo $decryptyn2 | tr -d ".gpg" );
if ( echo $fileyn | grep -q $fileyn /home/flo/Desktop/random_stuff/final.txt );
then 


autodetect= sudo cat /home/flo/Desktop/random_stuff/final.txt
autodetect1=$( cut -d ":" -f 1 <<< "$autodetect" ) 
autodetect2=$( cut -d ":" -f 2 <<< "$autodetect" ) 
autodetect3=$( cut -d ":" -f 3 <<< "$autodetect" )  

echo " Autodetected file $autodetect1"
echo " Autodetected iterations $autodetect2"
echo " Autodetected salt $autodetect3"
else 
echo "could not autodetect salt or iterations"
fi
echo "please input a password " 
stty -echo
read -p "Password :" passwrd; echo
stty echo  
echo "whith what salt ? "
read dsalt
echo "How many iterations ? "
read dit  
completed=$passwrd$dsalt
echo "the string to hash is $completed"
sleep 3 


iterated1=$( echo -n "$completed" | sha384sum ); 
iteratedd2=$( echo "$iterated1" | tr -d - );


for ((i=dit; i>=0; i--))
do

runningitd=$( echo -n $iteratedd2 | sha384sum )
iteratedd2=$runningitd
finald=$( echo "$iteratedd2" | tr -d - );

echo "$finald"
done

passwrd=$finald
echo "The final iterated hash is $dit:$dsalt:$passwrd"
echo $passwrd | sudo gpg -o "$decryptyn2.oreginal" -q --batch --passphrase-fd 0 --decrypt $decryptyn2  
echo "now decrypting " 
sudo bleachbit --clean bash.history --overwrite 
sleep 3
exit 1

#decryption end 

#generator 
else 
echo "running in encrypt mode "
fi
echo ""
sleep 2 
echo "please input your password to be hashed "
echo ""
stty -echo
read -p "Password :" x; echo
stty echo 
echo "$x" >> /home/flo/Desktop/random_stuff/test.txt
rawstring=$(cat /home/flo/Desktop/random_stuff/test.txt)
echo $rawstring
echo ""
echo "getting salt"
Random=$( wget -q -O /home/flo/Desktop/random_stuff/randombytes.txt https://www.random.org/cgi-bin/randbyte?nbytes=12&format=d );
echo "got salt"
echo ""
salt=$( cat /home/flo/Desktop/random_stuff/randombytes.txt );
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
complete=$rawstring$saltb64 >> /home/flo/Desktop/random_stuff/complete.txt
echo $complete
sleep 2
echo ""
iterations=500
echo "Do you want to treat iterations as a secret value for security increase ?"
echo "!!! Note that you will have to remember the iterations because they will not be outputted with the hash !!!"
echo ""
sleep 2
echo "treat iterations as a secret value ? ( Y/N )"
read itsecret 
echo "How many iterations do you want to have ? ( default 500 ) or ENTER for default "
read it 
if [[ $it == $blank ]];
then 
echo "Using default"
else 
iterations=$it
echo "using $iterations iterations "
fi
iterated=$( echo -n "$complete" | sha384sum ); 
iterated2=$( echo "$iterated" | tr -d - );

#Iteration loop 

for ((i=iterations; i>=0; i--))
do
runningit=$( echo -n $iterated2 | sha384sum )
iterated2=$runningit
final=$( echo "$runningit" | tr -d - );
echo "$final"
done 

#loop finished 

sleep 2
echo "shreddering all critical files " 
sudo shred -n 15 -z -u /home/flo/Desktop/random_stuff/randombytes.txt
sudo shred -n 15 -z -u /home/flo/Desktop/random_stuff/test.txt
sudo shred -n 15 -z -u /home/flo/Desktop/random_stuff/complete.txt
if [[ $itsecret == "Y" ]]
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

#generator end 

# encryption 


echo "" 
echo "Session key is $final"
echo ""
echo ""
echo "Destroy oreginal file after encryption ? ( Y/N )"
read destorgfile 
echo "Which file do you want to encrypt now ?"
echo ""
read filetoenc
filetoenc2=$( echo "$filetoenc" | tr -d "'");
sudo echo $final | sudo gpg --batch -q --passphrase-fd 0 -o "$filetoenc2.gpg" --symmetric --armor --cipher-algo AES256 -c "$filetoenc2" 
echo "writeing autodetection log "
echo "$filetoenc:$iterations:$saltb64" > /home/flo/Desktop/random_stuff/final.txt 
echo ""
echo "successfully encrypted "
sleep 3
if [[ $destorgfile == "Y" ]]
then 
sudo shred -f -n 15 -v -z -u $filetoenc2
echo ""
echo "Shreddered oreginal file "
else 
echo "Done"
fi 
