#install.packages("tidyverse")
library("tidyverse")

dat <- read.csv("L06091944.spa", sep = "|", skip = 1)
header <- read.csv("L06091944.spa", sep = "|", nrows = 1)
channel_starts <- which(grepl("Ch", colnames(header)))
channel_ends <- c(channel_starts[-1] - 1, ncol(dat))
channel_names <- colnames(header)[channel_starts]


bis <- dat$DB13U01
entropy <-dat$IMPEDNCE
time_date <- dat$Time
emg <- dat$EMGLOW01

df <- cbind( time_date, bis, entropy, emg)
df_limp <-df[-c(1:20), ]
bis_limp <-bis[c(21:length(bis))]

plot(bis_limp, type = "l")

bis_limp
label <- rep(0, length(bis_limp))
label[29:118] <- 1
label[153:363] <- 1
#label[83:168] <- 1
label[364:length(bis_limp)] <- 2
plot(bis, type = "l")
lines(label * max(bis_limp), col = 2, lwd=2)

df_final <- cbind(
  as.data.frame(df_limp),
  data.frame("attack" = label)
)

write.csv(df_final, "prueba.csv")

#PLOT function for the BIS values recorded
#raya_x = c(1:length(tim))
#raya_y = rep(88, length(tim))
#plot (tim,bis_limp, type="l", xlab = "Second's recorded", ylab="BIS value" , yaxp = c(50, 100, 25))
#lines(raya_x,raya_y,type= "l",lwd=1, col= "red")
#legend("bottomleft",col=c("black","red"),legend =c("BIS","Cut off"), lwd=3, bty = "n")


