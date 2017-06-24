About VSHG
-------------

VSHG is a standalone Addon for GPG ( Gnu privacy guard ) .
It uses the sha384 hash function for the password and 
AES256 for the final encryption . 
And also a standard Iteration of 500X .
It uses True random 12 byte salts .
So even if your pasphrase is very weak , it will reinforce it so that 
you dont have to worry about that anymore .
VSHG uses the last hash of the Iteration as session key for gpg .
Also it provides an Autodetection function for each file so that you
don´t have to remember either the salt or the iteration count . 

Why is VSHG so secure ?
-----------------------
Weak Password ? No problem !
VSHG uses a true random salt for each encrypted file , So your 
Passphrase will alway have a minimum of 12 byte in strenth .
You could even use the same password twice for different files .
The thing that makes VSHG so secure are the iterations .
500 iterations means the output of the string is hashed 500x 
with its output . 
The more iterations the more security there will be .
Even if you have the correct passphrase , but not the correct
amount of iterations it will not be able to decrypt .

The strength 
------------- 
A sha384 hash has 96 charakters with 16 possibilities for each charakter 
That makes 5.2*10^31 possibilities for each hash . 
But even if you calculated all possible sha384 hashes you still have the iterations 
So to effectively get the password it is (5.2*10^31) * Iterations 
( At least for computation power since you would already have all possible hashes
if you made 5.2*10^31 operations ). 
That would be increadybly time consuming .    
It would take ~ 9,6*10^9 Years for the strongest supercomputer at the time .
And on the encryption side : cracking an AES256 key takes 2^254,4 operations . 

Why should I use VSGH ?
-----------------------
* It is more easy to use than GPG core . 
* Someone that doesn´t have VSHG does not really have a chance of cracking the password .
* True random 12 byte salt 
* choosable Iteration count .
* choosable Salt . 
* Secret Iteration option .
* Can guarantee security even with relatively weak passwords ( > 5 charakters )
  ( if you have enough Iterations ) 
* Autodetection of Salt + Iteration count for each file . 
* Military standard AES-256 encryption instaed of the gpg standard CAST5 encryption .
* Erases Original file securely 

