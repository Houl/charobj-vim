# vim-charobj
Yet another **text-object delimited by given character** script

## Installation
Nothing special.
A not-too-old Vim is required (my gVim 7.3.420 fails to `.`-repeat correctly).

## Configuration
Setting up keys in the vimrc:

    " Operator-pending mode and Visual mode:
    :map <expr> am nwo#mappings#charobj#Plug('a')|nunmap am|sunmap am
    :map <expr> im nwo#mappings#charobj#Plug('i')|nunmap im|sunmap im

## Usage:
After an operator or while in Visual mode:

    im{char}
    am{char}

searches left and right for {char} and selects the region in between.  `am` includes the 2nd {char}.

It is possible to enter a digraph:

    im<C-K>{char1}{char2}
    am<C-K>{char1}{char2}

`[count]im` and `[count]am` is supported.
`.`-repetition is supported.

## Examples:
Delete region between two backslashes:

    dim\

Delete region between two backslashes, including the backslash that follows:

    dam\

## Notes:
Start and end of the region are always in the same line, by intention (not configurable for now).

The region extends to the start or end of the line when there is no matching character.

An existing Visual area is not extended, just redefined, using the start of the region.  This may or may not change, you can use the `f` keys to move around.

When the region is empty between two occurrences of {char} and the cursor is on the 2nd {char}, then `im{char}` selects the 2nd {char}.  Makes sense when repeating a delete.

## Other Notes:
Asking for a character does not put you in getchar-mode in the cmdline.

Dot-repetition does not ask for a character again.

## Credits:
thinca/vim-textobj-between: Text objects for a range between a character
https://github.com/thinca/vim-textobj-between

https://github.com/kana/vim-textobj-user

Paradigm: Patch to utilize undefined text-objects
https://groups.google.com/forum/#!msg/vim_dev/pZxLAAXxk0M/rW_ic3O4YxEJ
(still unofficial Vim patch from 2013)

## License
Copyright (c) Andy Wokula.  The Vim License applies.
