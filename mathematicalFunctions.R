#install.packages("zoo")
library("tidyverse")



read_bis_csv <- function(filename) {
  dat <- read.csv(filename,header= TRUE, sep = ",")
  #header <- read.csv(filename, nrows = 1)
  #channel_starts <- which(grepl("Ch", colnames(header)))
  #channel_ends <- c(channel_starts[-1] - 1, ncol(dat))
  #channel_names <- colnames(header)[channel_starts]
  #data.frame('bis' = dat$DB13U01.1,
  #           'label' = sample(0:1, nrow(dat), replace = TRUE)
  #)
}


interesting_stats <- function(bis) {
  
  c(mean(bis), sd(bis), getmode(bis), sd(bis)/mean(bis), max(bis), min(bis)) 
}

getmode <- function(v) {
  uniqv <- unique(v)
  uniqv[which.max(tabulate(match(v, uniqv)))]
}

all_files <- list.files(pattern = "*.csv")


all_results <- list()
i <- 1
window <- 5  # groups every 5 samples

library("zoo")  

for (file in all_files) {
  data <- read_bis_csv(file)
  bis <- data$bis
  my_stats <- rollapply(data$bis, window, interesting_stats, by = window)
  my_short_label <- rollapply(data$attack, window, getmode, by = window)
  whole_df <- cbind(
    as.data.frame(my_stats),
    data.frame("attack" = my_short_label),
    "file" = file
  )
  all_results[[i]] = whole_df
  i <- i + 1
}


single_df <- do.call(rbind, all_results)
write.csv(single_df, "resultados/single_df.csv")

single_df
