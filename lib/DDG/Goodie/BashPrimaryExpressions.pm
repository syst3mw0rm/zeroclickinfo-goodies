package DDG::Goodie::BashPrimaryExpressions;
# ABSTRACT: human-readable descriptions of bash shell expressions

use strict;
use warnings;

use DDG::Goodie;

triggers startend => 'bash if', 'bash';
primary_example_queries 'bash [ -z hello ]';
secondary_example_queries 'bash if [[ "abc" -lt "cba" ]]';

description 'Bash Primary Expressions Help';
name 'Bash Help';
source 'http://tille.garrels.be/training/bash/ch07.html';
attribution github => [ 'http://github.com/mintsoft', 'mintsoft' ];

category 'computing_tools';
topics 'sysadmin';

our %if_description = (
	'-a' => "true if ARG2 exists",
	'-b' => "true if ARG2 exists and is a block-special file",
	'-c' => "true if ARG2 exists and is a character-special file",
	'-d' => "true if ARG2 exists and is a directory",
	'-e' => "true if ARG2 exists",
	'-f' => "true if ARG2 exists and is a regular file",
	'-g' => "true if ARG2 exists and its SGID bit is set",
	'-h' => "true if ARG2 exists and is a symbolic link",
	'-k' => "true if ARG2 exists and its sticky bit is set",
	'-p' => "true if ARG2 exists and is a named pipe (FIFO)",
	'-r' => "true if ARG2 exists and is readable",
	'-s' => "true if ARG2 exists and has a size greater than zero",
	'-t' => "true if ARG2 descriptor FD is open and refers to a terminal",
	'-u' => "true if ARG2 exists and its SUID (set user ID) bit is set",
	'-w' => "true if ARG2 exists and is writable",
	'-x' => "true if ARG2 exists and is executable",
	'-O' => "true if ARG2 exists and is owned by the effective user ID",
	'-G' => "true if ARG2 exists and is owned by the effective group ID",
	'-L' => "true if ARG2 exists and is a symbolic link",
	'-N' => "true if ARG2 exists and has been modified since it was last read",
	'-S' => "true if ARG2 exists and is a socket",
	'-o' => "true if shell option ARG2 is enabled",
	'-z' => "true if the length of 'ARG2' is zero",
	'-n' => "true if the length of 'ARG2' is non-zero",
	'==' => "true if the strings ARG1 and ARG2 are equal",
	'!=' => "true if the strings ARG1 and ARG2 are not equal",
	'<' => "true if ARG1 string-sorts before ARG2 in the current locale",
	'>' => "true if ARG1 string-sorts after ARG2 in the current locale",
	'-eq' => "true if ARG1 and ARG2 are numerically equal",
	'-ne' => "true if ARG1 and ARG2 are not numerically equal",
	'-lt' => "true if ARG1 is numerically less than ARG2",
	'-le' => "true if ARG1 is numerically less than or equal to ARG2",
	'-gt' => "true if ARG1 is numerically greater than ARG2",
	'-ge' => "true if ARG1 is numerically greater than or equal to ARG2",
	'-nt' => "true if ARG1 has been changed more recently than ARG2 or if ARG1 exists and ARG2 does not",
	'-ot' => "true if ARG1 is older than ARG2 or ARG2 exists and ARG1 does not",
	'-ef' => "true if ARG1 and ARG2 refer to the same device and inode numbers"
);

my $css = share("style.css")->slurp();
sub append_css {
    my $html = shift;
    return "<style type='text/css'>$css</style>\n" . $html;
}

handle remainder => sub {
        # This checks if our arguments in the `if` statement are valid.
        my $re_args = '[^\[\]\s]+|".+"|\'.+\'';
    	my $re = qr/^
                    (?:if\s)?				# Match `if` if there is one.
                    [\[]{1,2}\s 			# Match `[[` inside the `if` statement.
                    ([!]\s)?     			# Capture the `!` in queries such as `bash if [ ! "something" -gt "150" ]`
                    (?:($re_args)\s)? 			# Capture the first argument in the `if`
                    (-[a-zA-Z]{1,2}|[<>]|[!=]{1,2})\s	# Capture the options such as `-lt` for less than.
                    ($re_args)\s			# Capture the second argument.
                    [\]]{1,2}				# Match `]]` that ends the `if` statement.
                   $/x;

	my ($not, $left_arg, $op, $right_arg) = ($_ =~ $re);

	return unless ($op && $right_arg);
	return unless $if_description{$op};
	
	my $text_output = $if_description{$op};
	$text_output =~ s/^true/false/ if $not;
	
	my $html_output = html_enc($text_output);
	my $html_right_arg = html_enc($right_arg);
	
	if ($left_arg) {
	    my $html_left_arg = html_enc($left_arg);
	    $text_output =~ s/ARG1/$left_arg/g;
	    $html_output =~ s/ARG1/<pre>$html_left_arg<\/pre>/g;	
	}
	
	$text_output =~ s/ARG2/$right_arg/g;
	$html_output =~ s/ARG2/<pre>$html_right_arg<\/pre>/g;
	
	my $intro = "The Bash expression <pre>" . html_enc($_) . "</pre> results to";
	return "$intro $text_output.", html => append_css("$intro $html_output."), heading => html_enc($_) . " (Bash)";
};

1;
