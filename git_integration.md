Git Integration
---------------
Here are some git aliases you might want to add to your global .gitconfig:

    [alias]
		gastly = "!f(){ git log -n 1 --format="%h" | aghast -; }; f"
		aghast = "!f(){ git checkout $(aghast \""$1 $2 $3"\"); }; f"

Usage:

    # Show the current commit
    $ git gastly
      Comfortable Fat Halo
     
    # Checkout a commit (don't put the name in quotes)
    $ git aghast Comfortable Fat Halo
