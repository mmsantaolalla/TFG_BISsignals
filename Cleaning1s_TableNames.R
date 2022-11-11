#FIX that there are only 2 states in attack (0 and 1)
#transform the 2s in 1s
#1 = attack
#2 = awake

dat <- read.csv("resultados/single_df.csv",header= TRUE, sep = ",")

attack <- dat$attack
i<-1

#for (at in attack) {
#  at=attack[i]
#  if(at>1){
#    attack[i]<-1
#  }
#  i<-i+1
#}

dat$attack <- attack
#dat %>% rename (V1 = mean)
#dat %>% rename (V2 = std)
#dat %>% rename (V3 = mode)
#dat %>% rename (V4 = std/mean)
#dat %>% rename (V5 = max)
#dat %>% rename (V6 = min)


colnames(dat)[2] <-"mean"
colnames(dat)[3] <-"std"
colnames(dat)[4] <-"mode"
colnames(dat)[5] <-"std/mean"
colnames(dat)[6] <-"max"
colnames(dat)[7] <-"min"

drop <- names(dat) %in% c("X")
dats<-dat[,!drop]

dat2 <- dats[dats$attack!= "2",] #eliminate

write.csv(dat2, "resultados/final_data.csv")

