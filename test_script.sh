echo -e "\n\nStarting test..."
echo "----------------------------------------------------------------------------"

OPTION=$1

FILE=./test_result.txt
SCRIPT_FILE=scripts2
rm grep.gcda

results=()

# make test case file into string array
scripts=()
while read line
do
	if [ -n "$line" ] && [ "${line:0:1}" != "#" ]
	then
		scripts+=("$line")
	fi
done < $SCRIPT_FILE

# execute each test case
case_max=0
for value in "${scripts[@]}"; do
	echo $value
	$value
	echo -e "\n----------------------------------------------------------------------------"
	
	RESULT=`gcov -nb grep.c`

	line=${RESULT#*:}
	line_percent=${line%%\%*}
	branch=${line#*:}
	branch_percent=${branch%%\%*}

	if [ $(echo $case_max'<'$branch_percent | bc -l) -eq 1 ]
	then
		case_max_script=$value
		case_max=$branch_percent
	fi

	results+="$value\t\t$branch_percent\n"
	
	rm grep.gcda
done

# make test suite which size is 3
if [ "$OPTION" == "-s" ]
then

	suite_max=0
	SCRIPT_SIZE=${#scripts[@]}
	for i in `seq 1 $(($SCRIPT_SIZE - 3))`
	do
		for j in `seq $(($i + 1)) $(($SCRIPT_SIZE - 2))`
		do
			for k in `seq $(($j + 1)) $(($SCRIPT_SIZE - 1))`
			do
				${scripts[i]} > /dev/null 2>&1
				${scripts[j]} > /dev/null 2>&1
				${scripts[k]} > /dev/null 2>&1
				
				RESULT=`gcov -nb grep.c`

				line=${RESULT#*:}
				line_percent=${line%%\%*}
				branch=${line#*:}
				branch_percent=${branch%%\%*}

				if [ $(echo $suite_max'<'$branch_percent | bc -l) -eq 1 ]
				then
					suite_max_scripts="${scripts[i]}\n${scripts[j]}\n${scripts[k]}"
					suite_max=$branch_percent
				fi

				rm grep.gcda
			done
		done
	done
fi

rm $FILE
for value in "${results[@]}"; do
	echo -e "$value" >> $FILE
done

sort -t$'\t' -k3 -g -r $FILE -o $FILE

echo -e "\n\nBranch coverages for each test cases"
echo -e "Test case\t\t\tBranch coverage"
cat $FILE

echo -e "\n\nTest case with max branch coverage"
echo "----------------------------------------------------------------------------"
echo -e "$case_max_script\t$case_max"

if [ "$OPTION" == "-s" ]
then
	echo -e "\n\nTest suite with max branch coverage"
	echo "----------------------------------------------------------------------------"
	echo -e "$suite_max_scripts\t$suite_max"
fi

echo -e "\nCoverages for all test cases"
echo "----------------------------------------------------------------------------"
# check for all test case
for value in "${scripts[@]}"; do
	# ignore message (include errors)
	$value > /dev/null 2>&1
done

echo "`gcov -cb grep.c`"
