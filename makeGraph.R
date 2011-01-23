## Plot a histogram from the bicycle revolution counter's data.
## To run this on the example file (generating Rplots.pdf), use:
##	R -f makeGraph.R exampleData.R "978 to Whole Foods"
## Get R: http://www.r-project.org/

## The x axis of the histogram will extend to include any intervals
##	with a count of at least THRESHOLD.
THRESHOLD <- 4

## Read the file, producing:
##	METERS_PER_REVOLUTION
##	intervalData with $counts and $intervals
args <- commandArgs()
if (length(args) < 5) {
	print(paste("usage: ", args[3], " <data R file> <title>"))
	q()
}
source(args[4])
## annotated with total distance later
title <- paste(args[5:length(args)], collapse=" ")

METERS_PER_KM <- 1000.0
MILES_PER_KM <- 0.621371192
MS_PER_HOUR <- 60*60*1000.0
## ms interval to km/h
convertUnits <- function(milliseconds) ((METERS_PER_REVOLUTION * (1/METERS_PER_KM)) / (milliseconds * (1/MS_PER_HOUR)) )

xmin <- intervalData$intervals[length(intervalData$intervals)-1]
xmax <- intervalData$intervals[1]
for(i in 1:length(intervalData$counts)) {
	if (intervalData$counts[i] > THRESHOLD) {
		xmin <- min(xmin, intervalData$intervals[i])
		xmax <- max(xmax, intervalData$intervals[i])
	}
}

total <- sum(intervalData$counts)
total <- total * METERS_PER_REVOLUTION * (1/METERS_PER_KM)
title <- sprintf("%s: %.2f km", title, total)

plot(convertUnits(intervalData$intervals), intervalData$counts, type='h', col="red", main=title, xlab="Speed (km/h)", ylab="Frequency", log="x", xlim=convertUnits(c(xmax, xmin)), yaxt="n", lwd=3, lend="square")

