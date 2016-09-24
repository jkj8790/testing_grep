echo -e "\n\nStarting test..."
echo "----------------------------------------------------------------------------"

FILE=./test_result.txt
THREE_FILE=./test_result_three.txt
SCRIPT_FILE=scripts2
rm grep.gcda


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
	$value > /dev/null 2>&1
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
	
	rm grep.gcda
done

# make test suite which size is 3
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

rm $THREE_FILE
for value in "${result_three[@]}"; do
	echo -e "$value" >> $THREE_FILE
done


echo -e "\n\nTest case with max branch coverage"
echo "----------------------------------------------------------------------------"
echo -e "$case_max_script\t$case_max"

echo -e "\n\nTest suite with max branch coverage"
echo "----------------------------------------------------------------------------"
echo -e "$suite_max_scripts\t$suite_max"

echo -e "\nCoverages for all test cases"
echo "----------------------------------------------------------------------------"
# check for all test case
for value in "${scripts[@]}"; do
	# ignore message (include errors)
	$value > /dev/null 2>&1
done

echo "`gcov -cb grep.c`"
