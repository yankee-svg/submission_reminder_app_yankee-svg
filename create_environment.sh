#!/bin/bash

mkdir -p submission_reminder_app

mkdir -p submission_reminder_app/app
mkdir -p submission_reminder_app/modules
mkdir -p submission_reminder_app/assets
mkdir -p submission_reminder_app/config

cat <<EOL > submission_reminder_app/app/reminder.sh
#!/bin/bash

source ./config/config.env
source ./modules/functions.sh

submissions_file="./assets/submissions.txt"

echo "Assignment: \$ASSIGNMENT"
echo "Days remaining to submit: \$DAYS_REMAINING days"
echo "--------------------------------------------"

check_submissions \$submissions_file
EOL
chmod u+x submission_reminder_app/app/reminder.sh

cat <<EOL > submission_reminder_app/modules/functions.sh
#!/bin/bash

# Function to read submissions file and output students who have not submitted
function check_submissions {
	local submissions_file=\$1
	echo "Checking submissions in \$submissions_file"

	# Skip the header and iterate through the lines
	while IFS=, read -r student assignment status; do
    	# Remove leading and trailing whitespace
    	student=\$(echo "\$student" | xargs)
    	assignment=\$(echo "\$assignment" | xargs)
    	status=\$(echo "\$status" | xargs)

    	# Check if assignment matches and status is 'not submitted'
    	if [[ "\$assignment" == "\$ASSIGNMENT" && "\$status" == "not submitted" ]]; then
        	echo "Reminder: \$student has not submitted the \$ASSIGNMENT assignment!"
    	fi
	done < <(tail -n +2 "\$submissions_file") # Skip the header
}
EOL
chmod u+x submission_reminder_app/modules/functions.sh

cp submissions.txt submission_reminder_app/assets/submissions.txt

cat <<EOL >> submission_reminder_app/assets/submissions.txt
keneth, Shell Navigation, not submitted
Maxime, Shell Navigation, late submitted,
Eddy, Shell Navigation, not submitted
Linda, Shell Navigation, submitted
Bright, Shell Navigation, not submitted
EOL

cat <<EOL > submission_reminder_app/config/config.env
# This is the config file
ASSIGNMENT="Shell Navigation"
DAYS_REMAINING=2
EOL
cat <<EOL > submission_reminder_app/startup.sh
#!/bin/bash

# Start reminder script if it exists
if [ -f "./app/reminder.sh" ]; then
	echo "Starting the reminder script..."
	bash ./app/reminder.sh
else
	echo "Reminder script not found. Exiting."
fi
EOL
chmod u+x submission_reminder_app/startup.sh


