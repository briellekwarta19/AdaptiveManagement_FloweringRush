library(plyr)
library(tidyverse)
library(here)
library(data.table)
library(scales)
library(RColorBrewer) 
library("cowplot")
library(rPref)
library(ggrepel)


#### NO REMOVAL ####
ncpath <- 'D:\\Chapter3\\results\\noremoval'
file_name = paste(ncpath, 'states_fin_truth.csv',sep = '/')
noremoval <- fread(file_name)
noremoval <- data.frame(noremoval)

nc.val <- mean(noremoval$state) -1 

noremoval$inv <- noremoval$state
noremoval$inv[noremoval$inv <= 2 ] <- 0
noremoval$inv[noremoval$inv > 2 ] <- 1
nc.inv <- mean(noremoval$inv)

#### States fin truth ####
##### States Fin truth dat A ####
path <- 'D:\\Chapter3\\results'
file_name = paste(path, 'true_finstates.csv',sep = '/')
finstate_truth <- fread(file_name)
finstate_truth <- data.frame(finstate_truth)

finstate_truth$rates <- paste0('(p = )', finstate_truth$detection, ',  \u03F5 = ', finstate_truth$eradication)
finstate_truth$rates2 <- paste0('(', finstate_truth$detection, ', ', finstate_truth$eradication, ")")

finstate_truth$state <- finstate_truth$state - 1

finstate_truth <- aggregate(state ~ sim + location + detection + eradication + budget + rates + rates2, 
                            data = as.data.frame(finstate_truth), 
                            FUN = mean)


finstate_truth$loc2 <- paste0(finstate_truth$location, finstate_truth$detection, finstate_truth$eradication)

finstate_truth <- finstate_truth %>% filter(#loc2 == 'smartepicenter0.250.75' |
                                            loc2 == 'smartepicenter0.50.75'  |
                                            loc2 == 'linear0.50.75')

colnames(finstate_truth)[5] <- 'Budget'

finstate_truthA <- finstate_truth
finstate_truthA$data <- 'A'


##### States Fin truth A+C ####
path <- 'D:\\Chapter3\\results_both'
file_name = paste(path, 'states_fin_truth.csv',sep = '/')
finstate_truth <- fread(file_name)
finstate_truth <- data.frame(finstate_truth)

finstate_truth$rates <- paste0('(p = )', finstate_truth$detection, ',  \u03F5 = ', finstate_truth$eradication)
finstate_truth$rates2 <- paste0('(', finstate_truth$detection, ', ', finstate_truth$eradication, ")")

finstate_truth$state <- finstate_truth$state - 1

finstate_truth <- aggregate(state ~ sim + location + detection + eradication + budget + rates + rates2, 
                            data = as.data.frame(finstate_truth), 
                            FUN = mean)

colnames(finstate_truth)[5] <- 'Budget'
finstate_truth$loc2 <- paste0(finstate_truth$location, finstate_truth$detection, finstate_truth$eradication)

finstate_truthAC <- finstate_truth 
finstate_truthAC$data <- 'AC' 

finstate_truth <- rbind(finstate_truthA, finstate_truthAC)

finstate_truth$loc2 <- paste0(finstate_truth$location, finstate_truth$detection, finstate_truth$eradication, finstate_truth$data )

detach(package:plyr)

budget20_suppress <- finstate_truthAC %>% 
  filter(Budget == 20) %>% 
  group_by(loc2) %>%
  summarise(mean_c = mean(state),
            max_c = max(state),
            lower = quantile(state, 0.1),
            upper = quantile(state, 0.9))

budget40_suppress <- finstate_truthAC %>% 
  filter(Budget == 40) %>% 
  group_by(loc2) %>%
  summarise(mean_c = mean(state),
            max_c = max(state),
            lower = quantile(state, 0.1),
            upper = quantile(state, 0.9))

budget60_suppress <- finstate_truthAC %>% 
  filter(Budget == 60) %>% 
  group_by(loc2) %>%
  summarise(mean_c = mean(state),
            max_c = max(state),
            lower = quantile(state, 0.1),
            upper = quantile(state, 0.9))

cols <- brewer.pal(12, "Paired") 
colors <- c(cols[1:4], cols[9:10])
colors <- c(colors[c(2,4)],'white')

colors2 <- c('grey50', 'purple')

finstate_truth <- finstate_truth %>% filter(Budget == 20)

finstate_truth %>% 
  ggplot(aes(x = loc2, y = state, fill = rates2, color =data,
             group = interaction(location, rates2, data)))+
  geom_boxplot() +
  geom_hline(yintercept = nc.val, linetype = 2) + 
  stat_summary(fun.y = mean, geom = "errorbar",
               aes(ymax = after_stat(y), ymin = after_stat(y),
                   group = interaction(location, rates)),
               width = .75, color = "black", linewidth = 1)+ 
  scale_x_discrete(breaks = c("smartepicenter0.50.75A",
                              "linear0.50.75A"),
                   labels=c(
                     "smartepicenter0.50.75A" = "smartepicenter",
                     "linear0.50.75A" = "Linear"))+
  
  scale_fill_manual(name = paste0('Management rates (p, ', '\u03F5 )'),
                    values = colors) +
  scale_color_manual(name = "Data",
                     values = colors2, 
                     labels = c('A', 'A + C'))+
  
  xlab("Site prioritization")+
  ylab("Average final invasion")+
  theme_bw() +   
  theme(strip.background=element_rect(colour="white",
                                      fill="white"),
        panel.border = element_rect(colour = "gray", size = 1.5), 
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.ticks = element_blank(),
        axis.text.x = element_text(hjust = 1))+
  facet_wrap(~Budget, nrow = 3, labeller = label_both)

#### States inv truth ####
##### States inv truth A ####
path <- 'D:\\Chapter3\\results'
file_name = paste(path, 'true_finstates.csv',sep = '/')
fininv_truth <- fread(file_name)
fininv_truth <- data.frame(fininv_truth)

fininv_truth$rates <- paste0('p = ', fininv_truth$detection, ', e = ', fininv_truth$eradication)
fininv_truth$rates2 <- paste0('(', fininv_truth$detection, ', ', fininv_truth$eradication, ")")

fininv_truth$inv <- fininv_truth$state
fininv_truth$inv[fininv_truth$inv <= 2 ] <- 0
fininv_truth$inv[fininv_truth$inv > 2 ] <- 1

fininv_truth <- aggregate(inv ~ sim + location + detection + eradication + budget + rates + rates2, 
                          data = as.data.frame(fininv_truth), 
                          FUN = mean)

fininv_truth <- fininv_truth %>% filter(detection < 1 & detection > 0)

fininv_truth$loc2 <- paste0(fininv_truth$location, fininv_truth$detection, fininv_truth$eradication)
colnames(fininv_truth)[c(2,5)] <- c('Location', 'Budget')

fininv_truth$data <- 'A'
fininv_truth <- fininv_truth %>% filter(#loc2 == 'smartepicenter0.250.75' |
                                              loc2 == 'smartepicenter0.50.75'  |
                                              loc2 == 'linear0.50.75')

fininv_truth$loc2 <- paste0(fininv_truth$Location, fininv_truth$detection, fininv_truth$eradication, fininv_truth$data)

fininv_truthA <- fininv_truth

##### States inv truth A+ C ####
path <- 'D:\\Chapter3\\results_both'
file_name = paste(path, 'states_fin_truth.csv',sep = '/')
fininv_truth <- fread(file_name)
fininv_truth <- data.frame(fininv_truth)

fininv_truth$rates <- paste0('p = ', fininv_truth$detection, ', e = ', fininv_truth$eradication)
fininv_truth$rates2 <- paste0('(', fininv_truth$detection, ', ', fininv_truth$eradication, ")")

fininv_truth$inv <- fininv_truth$state
fininv_truth$inv[fininv_truth$inv <= 2 ] <- 0
fininv_truth$inv[fininv_truth$inv > 2 ] <- 1

fininv_truth <- aggregate(inv ~ sim + location + detection + eradication + budget + rates + rates2, 
                            data = as.data.frame(fininv_truth), 
                            FUN = mean)


fininv_truth$loc2 <- paste0(fininv_truth$location, fininv_truth$detection, fininv_truth$eradication)

colnames(fininv_truth)[c(2,5)] <- c('Location', 'Budget')

fininv_truthAC <- fininv_truth 
fininv_truthAC$data <- 'AC' 
fininv_truthAC$loc2 <- paste0(fininv_truthAC$Location, fininv_truthAC$detection, fininv_truthAC$eradication, fininv_truthAC$data )

fininv_truth <- rbind(fininv_truthA, fininv_truthAC)

budget20_contain <- fininv_truthAC %>% 
  filter(Budget == 20) %>% 
  group_by(loc2) %>%
  summarise(mean_c = mean(inv),
            max_c = max(inv),
            lower = quantile(inv, 0.1),
            upper = quantile(inv, 0.9))

budget40_contain  <- fininv_truthAC %>% 
  filter(Budget == 40) %>% 
  group_by(loc2) %>%
  summarise(mean_c = mean(inv),
            max_c = max(inv),
            lower = quantile(inv, 0.1),
            upper = quantile(inv, 0.9))

budget60_contain <- fininv_truthAC %>% 
  filter(Budget == 60) %>% 
  group_by(loc2) %>%
  summarise(mean_c = mean(inv),
            max_c = max(inv),
            lower = quantile(inv, 0.1),
            upper = quantile(inv, 0.9))

cols <- brewer.pal(12, "Paired") 
colors <- c(cols[1:4], cols[9:10])
colors <- c(colors[c(2,4)],'white')

colors2 <- c('grey50', 'purple')

fininv_truth <- fininv_truth %>% filter(Budget == 20)

fininv_truth %>% 
  ggplot(aes(x = loc2, y = inv, fill = rates2, color =data,
             group = interaction(Location, rates2, data)))+
  geom_boxplot() +
  geom_hline(yintercept = nc.inv, linetype = 2) + 
  stat_summary(fun.y = mean, geom = "errorbar",
               aes(ymax = after_stat(y), ymin = after_stat(y),
                   group = interaction(Location, rates)),
               width = .75, color = "black", linewidth = 1)+ 
  scale_x_discrete(breaks = c("smartepicenter0.50.75A",
                              "linear0.50.75A"),
                   labels=c(
                     "smartepicenter0.50.75A" = "smartepicenter",
                     "linear0.50.75A" = "Linear"))+
  
  scale_fill_manual(name = paste0('Management rates (p, ', '\u03F5 )'),
                    values = colors) +
  scale_color_manual(name = "Data",
                     values = colors2, 
                     labels = c('A', 'A + C'))+
  
  xlab("Site prioritization")+
  ylab("Average final % invaded")+
  theme_bw() +   
  theme(strip.background=element_rect(colour="white",
                                      fill="white"),
        panel.border = element_rect(colour = "gray", size = 1.5), 
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.ticks = element_blank(),
        axis.text.x = element_text(hjust = 1))+
  facet_wrap(~Budget, nrow = 3, labeller = label_both)

#### Bias state ####
##### Bias state A ####
path <- 'D:\\Chapter3\\results'
file_name = paste(path, 'bais_states.csv',sep = '/')
bias_state <- fread(file_name)
bias_state <- data.frame(bias_state)

bias_state$rates <- paste0('p = ', bias_state$detection, ', e = ', bias_state$eradication)


bias_state$loc2 <- paste0(bias_state$location, bias_state$detection, bias_state$eradication)
bias_state$rates2 <- paste0('(', bias_state$detection, ', ', bias_state$eradication, ")")
colnames(bias_state)[8] <- 'Budget'

bias_state$data <- 'A'
bias_state <- bias_state %>% filter(#loc2 == 'smartepicenter0.250.75' |
                                          loc2 == 'smartepicenter0.50.75'  |
                                          loc2 == 'linear0.50.75')

bias_state$loc2 <- paste0(bias_state$location, bias_state$detection, bias_state$eradication, bias_state$data)
bias_stateA <- bias_state

##### Bias state A+ C ####
path <- 'D:\\Chapter3\\results_both'
file_name = paste(path, 'bias_state.csv',sep = '/')
bias_state <- fread(file_name)
bias_state <- data.frame(bias_state)

bias_state$rates <- paste0('p = ', bias_state$detection, ', e = ', bias_state$eradication)


bias_state$loc2 <- paste0(bias_state$location, bias_state$detection, bias_state$eradication)
bias_state$rates2 <- paste0('(', bias_state$detection, ', ', bias_state$eradication, ")")

colnames(bias_state)[8] <- 'Budget'

bias_state$data <- 'AC'
bias_state$loc2 <- paste0(bias_state$location, bias_state$detection, bias_state$eradication, bias_state$data)
bias_stateAC <- bias_state

budget20_biasstate <- bias_stateAC %>% 
  filter(Budget == 20) %>% 
  group_by(loc2) %>%
  summarise(mean_c = mean(rel.bias),
            max_c = max(rel.bias))

budget40_biasstate <- bias_stateAC %>% 
  filter(Budget == 40) %>% 
  group_by(loc2) %>%
  summarise(mean_c = mean(rel.bias),
            max_c = max(rel.bias))

budget60_biasstate <- bias_stateAC %>% 
  filter(Budget == 60) %>% 
  group_by(loc2) %>%
  summarise(mean_c = mean(rel.bias),
            max_c = max(rel.bias))

bias_state <- rbind(bias_stateAC, bias_stateA)

bias_state  <- bias_state  %>% filter(Budget == 20)

bias_state %>% 
  ggplot(aes(x = loc2, y = rel.bias, fill = rates2, color =data,
             group = interaction(location, rates2, data)))+
  geom_boxplot() +
  geom_hline(yintercept = 0, linetype = 2) + 
  stat_summary(fun.y = mean, geom = "errorbar",
               aes(ymax = after_stat(y), ymin = after_stat(y),
                   group = interaction(location, rates)),
               width = .75, color = "black", linewidth = 1)+ 
  scale_x_discrete(breaks = c("smartepicenter0.50.75A",
                              "linear0.50.75A"),
                   labels=c(
                     "smartepicenter0.50.75A" = "smartepicenter",
                     "linear0.50.75A" = "Linear"))+
  
  scale_fill_manual(name = paste0('Management rates (p, ', '\u03F5 )'),
                    values = colors) +
  scale_color_manual(name = "Data",
                     values = colors2, 
                     labels = c('A', 'A + C'))+
  
  xlab("Site prioritization")+
  ylab("State relative bias")+
  theme_bw() +   
  theme(strip.background=element_rect(colour="white",
                                      fill="white"),
        panel.border = element_rect(colour = "gray", size = 1.5), 
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.ticks = element_blank(),
        axis.text.x = element_text(hjust = 1))+
  facet_wrap(~Budget, nrow = 3, labeller = label_both)

##### Bias state- time ####
bias_state_years <- bias_state %>%
  group_by(location, year, rates, rates2, Budget) %>%
  summarise(mean_b = mean(rel.bias),
            lower = quantile(rel.bias, 0.05),
            upper = quantile(rel.bias, 0.95))

colnames(bias_state_years)[c(1,5)] <- c("Prioritization", "Budget")

bias_state_years$Prioritization[bias_state_years$Prioritization == "smartepicenter"] <- 'smartepicenter'
bias_state_years$Prioritization[bias_state_years$Prioritization == "linear"] <- 'Linear'
bias_state_years$Prioritization[bias_state_years$Prioritization == "hstate"] <- 'High invasion'

ggplot(bias_state_years, aes(x = year, y = mean_b, ymin = lower, ymax = upper, color = rates2))+
  geom_point()+
  geom_errorbar()+
  geom_hline(yintercept = 0, linetype = 2) + 
  scale_x_continuous(breaks = c(2,4,6,8,10)) +
  scale_color_manual(name = paste0('Management rates (p, ', '\u03F5 )'),
                     values = colors) +
  ylab("State relative bias ")+
  xlab("Year")+
  theme_bw() +   
  theme(strip.background=element_rect(colour="white",
                                      fill="white"),
        panel.border = element_rect(colour = "gray", size = 1.5), 
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.ticks = element_blank(),
        axis.text.x = element_text(hjust = 1))+
  facet_wrap(~Budget + Prioritization, nrow = 3, labeller = label_both)

#---- SUBSET ----#

bias_state_yearssub <- bias_state_years %>% filter(rates == "p = 0.75, e = 0.5" | rates == "p = 0.25, e = 0.75"|
                                                   rates == "p = 0.75, e = 0.75" | rates == "p = 0.5, e = 0.75")



colors_sub <- colors[c(2,4,5,6)]

ggplot(bias_state_yearssub, aes(x = year, y = mean_b, ymin = lower, ymax = upper, color = rates2))+
  geom_point()+
  geom_errorbar()+
  geom_hline(yintercept = 0, linetype = 2) + 
  scale_x_continuous(breaks = c(2,4,6,8,10)) +
  scale_color_manual(name = paste0('Management rates (p, ', '\u03F5 )'),
                    values = colors_sub) +
  ylab("State relative bias ")+
  xlab("Year")+
  theme_bw() +   
  theme(strip.background=element_rect(colour="white",
                                      fill="white"),
        panel.border = element_rect(colour = "gray", size = 1.5), 
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.ticks = element_blank(),
        axis.text.x = element_text(hjust = 1))+
  facet_wrap(~Budget + Prioritization, nrow = 3, labeller = label_both)


#### Bias params ####
file_name = paste(path, 'bias_params.csv',sep = '/')
bias_param <- fread(file_name)
bias_param <- data.frame(bias_param)

bias_param$rates <- paste0('p = ', bias_param$detection, ', e = ', bias_param$eradication)


bias_param$loc2 <- paste0(bias_param$location, bias_param$detection, bias_param$eradication)

###### Detection bias ####
bias_param_detect  <- bias_param %>% filter(param %in% c("B0.p.h", "B0.p.h", "B1.p.l", "B1.p.h"))

budget20_bias_param_detect <- bias_param_detect %>% 
  filter(budget == 20) %>% 
  group_by(loc2) %>%
  summarise(mean_c = mean(rel.bias))

budget40_bias_param_detect <- bias_param_detect %>% 
  filter(budget == 40) %>% 
  group_by(loc2) %>%
  summarise(mean_c = mean(rel.bias))

budget60_bias_param_detect <- bias_param_detect %>% 
  filter(budget == 60) %>% 
  group_by(loc2) %>%
  summarise(mean_c = mean(rel.bias))


###### Time #######
bias_param_detect$rates2 <- paste0('(', bias_param_detect$detection, ', ', bias_param_detect$eradication, ")")

bias_param_detect_years <- bias_param_detect %>%
  group_by(location, year, rates, rates2, budget) %>%
  summarise(mean_b = mean(rel.bias),
            lower = quantile(rel.bias, 0.05),
            upper = quantile(rel.bias, 0.95))

colnames(bias_param_detect_years)[c(1,5)] <- c("Prioritization", "Budget")

bias_param_detect_years$Prioritization[bias_param_detect_years$Prioritization == 'smartepicenter'] <- 'smartepicenter'
bias_param_detect_years$Prioritization[bias_param_detect_years$Prioritization == 'hstate'] <- 'High invasion'
bias_param_detect_years$Prioritization[bias_param_detect_years$Prioritization == 'linear'] <- 'Linear'

ggplot(bias_param_detect_years, 
       aes(x = year, y = mean_b, ymin = lower, ymax = upper, color = rates2))+
  geom_point()+
  geom_errorbar()+
  geom_hline(yintercept = 0, linetype = 2) + 
  scale_x_continuous(breaks = c(2,4,6,8, 10)) +
  scale_color_manual(name = paste0('Management rates (p, ', '\u03F5 )'),
                     values = colors) +
  ylab(paste0('p parameters relative bias'))+
  xlab("Year")+
  theme_bw() +   
  theme(strip.background=element_rect(colour="white",
                                      fill="white"),
        panel.border = element_rect(colour = "gray", size = 1.5), 
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.ticks = element_blank(),
        axis.text.x = element_text(hjust = 1))+
  facet_wrap(~Budget + Prioritization, nrow = 3, labeller = label_both, scales = "free")

#----- SUBSET ----#

bias_param_detect_yearssub <- bias_param_detect_years %>% filter(rates == "p = 0.5, e = 0.75" | 
                                                                   rates == "p = 0.25, e = 0.5"|
                                                                   rates == "p = 0.75, e = 0.5"|
                                                                   rates == "p = 0.25, e = 0.75")

colors_sub <- colors[c(1,2,4,5)]

ggplot(bias_param_detect_yearssub, 
       aes(x = year, y = mean_b, ymin = lower, ymax = upper, color = rates2))+
  geom_point()+
  geom_errorbar()+
  geom_hline(yintercept = 0, linetype = 2) + 
  scale_x_continuous(breaks = c(2,4,6,8, 10)) +
  scale_color_manual(name = paste0('Management rates (p, ', '\u03F5 )'),
                     values = colors_sub) +
  ylab(paste0('p parameters relative bias'))+
  xlab("Year")+
  theme_bw() +   
  theme(strip.background=element_rect(colour="white",
                                      fill="white"),
        panel.border = element_rect(colour = "gray", size = 1.5), 
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.ticks = element_blank(),
        axis.text.x = element_text(hjust = 1))+
  facet_wrap(~Budget + Prioritization, nrow = 3, labeller = label_both, scales = "free")

###### Eradication bias ####
bias_param_eps  <- bias_param %>% filter(param %in% c("B0.eps.h", "B0.eps.h", "B1.eps.l", "B1.eps.h"))

budget20_bias_param_eps <- bias_param_eps %>% 
  filter(budget == 20) %>% 
  group_by(loc2) %>%
  summarise(mean_c = mean(rel.bias))

budget40_bias_param_eps <- bias_param_eps %>% 
  filter(budget == 40) %>% 
  group_by(loc2) %>%
  summarise(mean_c = mean(rel.bias))

budget60_bias_param_eps <- bias_param_eps %>% 
  filter(budget == 60) %>% 
  group_by(loc2) %>%
  summarise(mean_c = mean(rel.bias))

###### Time #######
bias_param_eps$rates2 <- paste0('(', bias_param_eps$detection, ', ', bias_param_eps$eradication, ")")

bias_param_eps_years <- bias_param_eps %>%
  group_by(location, year, rates, rates2, budget) %>%
  summarise(mean_b = mean(rel.bias),
            lower = quantile(rel.bias, 0.05),
            upper = quantile(rel.bias, 0.95))

colnames(bias_param_eps_years)[c(1,5)] <- c("Prioritization", "Budget")

bias_param_eps_years$Prioritization[bias_param_eps_years$Prioritization == 'smartepicenter'] <- 'smartepicenter'
bias_param_eps_years$Prioritization[bias_param_eps_years$Prioritization == 'hstate'] <- 'High invasion'
bias_param_eps_years$Prioritization[bias_param_eps_years$Prioritization == 'linear'] <- 'Linear'

ggplot(bias_param_eps_years, 
       aes(x = year, y = mean_b, ymin = lower, ymax = upper, color = rates2))+
  geom_point()+
  geom_errorbar()+
  geom_hline(yintercept = 0, linetype = 2) + 
  scale_x_continuous(breaks = c(2,4,6,8, 10)) +
  scale_color_manual(name = paste0('Management rates (p, ', '\u03F5 )'),
                     values = colors) +
  ylab(paste0('\u03F5 parameters relative bias'))+
  xlab("Year")+
  theme_bw() +   
  theme(strip.background=element_rect(colour="white",
                                      fill="white"),
        panel.border = element_rect(colour = "gray", size = 1.5), 
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.ticks = element_blank(),
        axis.text.x = element_text(hjust = 1))+
  facet_wrap(~Budget + Prioritization, nrow = 3, labeller = label_both, scales = "free")

#----- SUBSET ----#

bias_param_eps_yearssub <- bias_param_eps_years %>% filter(rates == "p = 0.5, e = 0.75" | rates == "p = 0.25, e = 0.75" |
                                                             rates == "p = 0.75, e = 0.75")

colors_sub <- colors[c(2,4,6)]

ggplot(bias_param_eps_yearssub, 
       aes(x = year, y = mean_b, ymin = lower, ymax = upper, color = rates2))+
  geom_point()+
  geom_errorbar()+
  geom_hline(yintercept = 0, linetype = 2) + 
  scale_x_continuous(breaks = c(2,4,6,8, 10)) +
  scale_color_manual(name = paste0('Management rates (p, ', '\u03F5 )'),
                     values = colors_sub) +
  ylab(paste0('\u03F5 parameters relative bias'))+
  xlab("Year")+
  theme_bw() +   
  theme(strip.background=element_rect(colour="white",
                                      fill="white"),
        panel.border = element_rect(colour = "gray", size = 1.5), 
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.ticks = element_blank(),
        axis.text.x = element_text(hjust = 1))+
  facet_wrap(~Budget + Prioritization, nrow = 3, labeller = label_both, scales = "free")

