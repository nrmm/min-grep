# min-grep
A minimal implementation of the grep utility. It simplies print lines matching a given regex.

Min-grep has the following features:

	- search recursively in a directory
	- print line numbers matching a pattern
	- match case insensitive

Nothing else ;-)

It's meant for systems that don't have mechanisms to search files with a given content.

#INSTALL

There's no installation. All you need is a Perl environment.

#EXAMPLES

Search recursively all the files under the current directory and print line
numbers when a match is found:

> perl min-grep -rn "foo" .

Print all lines with floating point numbers:

> perl min-grep "\d+\.\d+" foo.txt
