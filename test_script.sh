echo -e "\n\nStarting test..."
echo "----------------------------------------------------------------------------"

FILE=./test_result.txt
THREE_FILE=./test_result_three.txt
SCRIPT_FILE=scripts2
rm grep.gcda

results=()
result_three=()
scripts=()

# make test case file into string array
while read line
do
	if [ -n "$line" ] && [ "${line:0:1}" != "#" ]
	then
		scripts+=("$line")
	fi
done < $SCRIPT_FILE

# execute each test case
for value in "${scripts[@]}"; do
	echo "$value"
	$value
	echo -e "\n----------------------------------------------------------------------------"
	RESULT=`gcov -nb grep.c`

	line=${RESULT#*:}
	line_percent=${line%%\%*}
	branch=${line#*:}
	branch_percent=${branch%%\%*}

	results+="$value\t\t$branch_percent\n" 
	rm grep.gcda
done

# make test suite which size is 3
echo ${#scripts[@]}
SCRIPT_SIZE=${#scripts[@]}
for i in `seq 1 $(($SCRIPT_SIZE - 3))`
do
	for j in `seq $(($i + 1)) $(($SCRIPT_SIZE - 2))`
	do
		for k in `seq $(($j + 1)) $(($SCRIPT_SIZE - 1))`
		do
			${scripts[i]}
			${scripts[j]}
			${scripts[k]}
			
			RESULT=`gcov -nb grep.c`

			line=${RESULT#*:}
			line_percent=${line%%\%*}
			branch=${line#*:}
			branch_percent=${branch%%\%*}

			result_three+="$i,$j,$k \t\t$branch_percent\n" 
			rm grep.gcda
		done
	done
done

rm $FILE
for value in "${results[@]}"; do
	echo -e "$value" >> $FILE
done

rm $THREE_FILE
for value in "${result_three[@]}"; do
	echo -e "$value" >> $THREE_FILE
done

sort -t$'\t' -k3 -g -r $FILE -o $FILE

echo -e "\n\nBranch coverage for each test cases"
echo "----------------------------------------------------------------------------"
echo -e "Test case\t\t\tBranch coverage"
cat $FILE

echo -e "\nCoverages for all test cases"
echo "----------------------------------------------------------------------------"
# check for all test case
for value in "${scripts[@]}"; do
	# ignore message (include errors)
	$value > /dev/null 2>&1
done

echo "`gcov -cb grep.c`"
