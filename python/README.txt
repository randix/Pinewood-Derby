Rules
-----

The races are run against the Fast Track K2 race timer. We will not
use the elimination method.  Each car will run in each track, and
we track the times of each run. A car that fails to finish the run
will be specially flagged as not finished.  There are two ways: 1)
the car came off of its track: 'crash', or 2) it stopped before
finishing: 'stop'.

We may decide to throw out the slowest times for all cars.

(Since we are running against the clock, and not against elimination,
allowing a late registration would not be a technical problem.)

Installation
------------

Make sure you have 'python3' installed.  This program requires adding
pyserial to the python libraries.  See:
https://www.python.org/downloads/
https://pypi.org/project/pyserial/

Registration
------------

Fill out the 'Derby' spreadsheet.  This includes the Car number,
the Name, the Age, and the AWANA Group for each participant.

Preparation
-----------

Open the 'Derby' spreadsheet and a terminal. Copy the Car number
column.

Open the 'cars.txt' and paste the Car number column. You should
have a file with a vertical list of the cars.

Run the 'schedule.py' program.
Type "./schedule.py".
This will randomize the cars and create a 'cars-random.txt' file.

Open the 'Heats' spreadsheet. Delete any data in the Tracks columns.
 - Copy and paste the 'cars-random.txt' data into the Track1 column.
 - Then go down about 1/4 of the number of cars (i.e., if there are
   40 cars, put the curser in Track2, about row 10) and paste the
   column of cars again.
 - Put the curser in Track3 about 1/2 down for the number of cars
   (i.e., if there are 40 cars, put the curser in Track3 about row 20)
   and paste the column of cars again.
 - Finally, put the curser in Track 4, about 3/4 down for the number
   of cars, and paste the column of cars again.
Now, cut and paste the cars below the number of cars from the bottom
of the column back to the top of the column.
Do the same for tracks 3 and 4.
Save the 'Heats' file.

If possible, print several copies of the Heats spreadsheet.

Racing
------

Open the 'Heats' spreadsheet. 
Run the 'derby.py' program.
Type "derby.py".

When the 'derby.py' program prompts for input, copy the current
heat row from the 'Heats' spreadsheet and paste it into the 'derby.py'
program.

MAKE VERY CERTAIN THAT THE RACE STARTER HAS THE PROPER CARS IN THE
PROPER TRACKS FOR THE RACE HEAT.
This should probably be accomplished with a starter assistent calling
out the car numbers, and a race timer assistant helping to verfiy
that the numbers entered into the 'derby.py' program and the cars
actually being started!

Continue for all heats.

Scoring
-------

Run the 'score.py' program.
Type "./score.py 3".

This produces a 'scores.csv' file. Open this file and copy'n'paste
into the 'Derby' spreadsheet.  Be certain that the car numbers
align! Check all of them!

The 'Derby' spreadsheet can now be sorted by age, AWANA group, or
overall, and then subsorted by the Sum times to find a complete
ranking for any desired group or subgroup. The sums are for the
best race, the best 2 races, the best 3 races, and all 4 races.
