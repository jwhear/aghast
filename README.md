aghast: the human-friendly hash translator
 
USAGE
-----
   Aghast translates unpronounceable hashes into friendly names and vice-versa.
For example, we can invoke aghast with some hashes we got from git:

    $ aghast 9f23a18123901 a2ce23
     Cluttered Essential Stingray
     Colorful Ill Cockroach

   Note that Aghast only bothers with the first six characters of the hash, thus
these produce the same results:

    $ aghast 9f23a18123901 9f23a1812 9f23a1
     Cluttered Essential Stingray
     Cluttered Essential Stingray
     Cluttered Essential Stingray

   Aghast can also go the other way, translating the human-friendly names back into
hashes:

    $ aghast 'Cluttered Essential Stingray' 'Colorful Ill Cockroach'
     9f23a1
     a2ce23 

   Be sure to surround those names in quotes when on the command line!  Aghast will
also gladly read from STDIN for you if '-' is supplied as an argument:

    $ echo '9f23a1' | ./aghast -
     Cluttered Essential Stingray

ABOUT
-----
   Written by Justin Whear <justin@economicmodeling.com>
