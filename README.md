About VSHG
-------------

VSHG ( Very secure hash generator ) is a standalone Addon for GnuPG ( Gnu privacy guard ) .
It is written as a shell script and is designed arount the Unix/Linux filesystem and commands . 
VSHG uses the sha384 and the Argon2 hash function for the password and 
**AES-256-CFB** + **CAST5-128-CFB** in cascade for the final encryption . 

And also a standard sha384 iteration count of **800** iterations + **15** & **500** iterations for Argon2i + d

It uses True random **12 byte salts** .
So even if your passphrase is very weak , it will reinforce it so that 
you dont have to worry about that anymore .

VSHG uses the last hash of the Iteration as session key for Gnupg .
Also it provides an Autodetection function for each file so that you
don't have to remember either the salt or the iteration count . 

Optionally you can use a keyfile as authentification method .

Why is VSHG so secure ?
-----------------------
Weak Password ? No problem !

( Useing a strong Passphrase is still recommanded ) 

VSHG uses a true random salt for each encrypted file , So your 
Passphrase will always have a minimum of 12 byte in strength .
You could even use the same password twice for different files .
The thing that makes VSHG so secure are the iterations .
800 iterations means the output of the string is hashed 800x 
with its output . 
The more iterations the more security there will be .
Even if you have the correct passphrase , but not the correct
amount of iterations it will not be able to decrypt .

VSHG uses some of the most adwanced forms of memory hard Key derivation functions which are 
Argon2i and Argon2d . The already iterated key will be passed throu Argon2 a total of 515 times 
and therefore ensure the resistance against the biggest threats of Key derivation functions 
Namely : Graphical Processing Units , Field programmanble gate arrys and 
Application specific integrated circuits ( GPU , FPEGA , ASIC ) .

The actual encryption is performed with the highest level of security possible in Gnupg . 

-The string to key ( s2k ) **algo** ( which is the KDF of Gnupg ) was reinforced from sha1 to **sha512** . 

-The **s2k mode** was set to **3** which means that a 8 bit salt is applied and the iterated .

-The **s2k count** was set to **65011712** which is the highest possible number of iterations . 

-The **s2k algo** was set to **AES256** and **CAST5** in cascade . 

The AES 256 encrypted file is securely deleted so that **only** the AES256(Cast5()) encrypted file is put out . 

Why should I use VSHG ? 
-----------------------
* It is more easy to use than GPG core . 
* Can encrypt folders by turning them into Zip files .
* Someone that doesn´t have VSHG does not really have a chance of cracking the password .
* True random 12 byte salt 
* choosable Iteration count .
* choosable Salt . 
* choosable Keyfile .
* True random Keyfile . 
* Very good resistance to side channel attacks ( eg . timeing attacks ).
* Very resistent towards GPU based attacks 
* Can guarantee security even with relatively weak passwords ( > 5 charakters )
  ( if you have enough Iterations ) 
* Autodetection of Salt + Iteration count for each file . 
* Military standard AES-256 encryption + the gpg standard CAST5 encryption .
* Uses the gpg s2k mode 3 + sha512 with the maximum count of 65011712 .
* Erases Original file securely .

Known bugs
------------

* Removal of original file will fail if there is a **space in the path/name** . 
* Encryption and zipping of folder will fail if the folder has a **space in it's path/name** . 
* Some temporary files like randomness are sometimes not removed properly after repeated useage .  
* problems with cleaning bash history 
