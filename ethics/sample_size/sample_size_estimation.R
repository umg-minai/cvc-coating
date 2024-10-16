## Assumptions
##
## rate of events (was 0.73 in previous CRT study)
p.event.assumed <- 0.6
## delta of hazard rate between both arms (was 2.5 in previous CRT study)
hr.assumed <- 2.0
## targeted power
power <- 0.8
## allowed alpha error
alpha <- 0.05

## Calculate number of needed events for a two arm survival study.
##
## @param delta numeric(1), delta in hazard ratio
## @param alpha numeric(1), alpha level
## @param beta numeric(1), 1 - power
##
## @return number of total needed events
##
## @source
## Dirk F. Moore, Applied Survival Analysis Using R, Springer, 2016, page 169.
## doi: 10.1007/978-3-319-31245-3
##
needed_events <- function(delta, alpha = 0.05, beta = 0.2) {
    ## proportion of control group (equal sized: p == 0.5)
    p <- 0.5
    z <- qnorm(c(alpha, beta), lower.tail = FALSE)
    sum(z)^2 / (p * (1 - p) * log(delta)^2)
}

## data from our previous CRT study
arr <- structure(list(CRT = c(FALSE, TRUE, FALSE, TRUE, TRUE, TRUE,
FALSE, TRUE, TRUE, TRUE, TRUE, TRUE, FALSE, TRUE, TRUE, TRUE,
TRUE, FALSE, TRUE, FALSE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE,
TRUE, FALSE, FALSE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, FALSE,
TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, FALSE, TRUE, TRUE,
FALSE, TRUE, TRUE, TRUE, TRUE, FALSE, TRUE, TRUE, FALSE, TRUE,
TRUE, FALSE, TRUE, FALSE, FALSE, FALSE, TRUE), FUP = c(5L, 1L,
1L, 3L, 11L, 1L, 11L, 1L, 1L, 1L, 1L, 1L, 1L, 13L, 3L, 1L, 5L,
3L, 3L, 5L, 1L, 1L, 3L, 1L, 3L, 7L, 13L, 7L, 5L, 1L, 1L, 3L,
1L, 1L, 5L, 9L, 1L, 1L, 3L, 1L, 1L, 1L, 1L, 1L, 3L, 5L, 1L, 1L,
1L, 7L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 3L, 7L, 5L, 3L, 3L, 7L),
    ManLu = c("Arrow5", "Arrow3", "Arrow3", "Arrow4", "Arrow5",
    "Arrow3", "Arrow4", "Arrow3", "Arrow3", "Arrow5", "Arrow5",
    "Arrow5", "Arrow5", "Arrow3", "Arrow5", "Arrow3", "Arrow5",
    "Arrow3", "Arrow3", "Arrow3", "Arrow4", "Arrow4", "Arrow3",
    "Arrow4", "Arrow5", "Arrow5", "Arrow5", "Arrow3", "Arrow4",
    "Arrow5", "Arrow3", "Arrow4", "Arrow4", "Arrow4", "Arrow5",
    "Arrow5", "Arrow5", "Arrow3", "Arrow5", "Arrow4", "Arrow5",
    "Arrow3", "Arrow4", "Arrow3", "Arrow3", "Arrow5", "Arrow5",
    "Arrow4", "Arrow5", "Arrow5", "Arrow5", "Arrow5", "Arrow5",
    "Arrow4", "Arrow3", "Arrow5", "Arrow5", "Arrow5", "Arrow5",
    "Arrow3", "Arrow4", "Arrow5", "Arrow5")), row.names = c(NA, -63L),
class = "data.frame")

## 4 lumen was chlorhexidin coated (CHX) and 3 + 5 lumen was without coating
arr$CHX <- factor(
    ifelse(arr$ManLu != "Arrow4", "none", "chx"),
    levels = c("none", "chx")
)

## the combined HR for 3 and 5 lumen was ~ 1.6 and for 4 lumen, coated ~ 5
## However, we consider a delta_HR of 2 an important difference and use this
## as conservative estimate (instead of delta_HR of 2.5 (5 / 2)).
delta <- c(1.5, 2, 2.5)

n.events <- ceiling(
    needed_events(delta = delta, alpha = alpha, beta = 1 - power)
)
names(n.events) <- paste0("delta_hr=", delta)

## probability of events in CRT
p.event <- round(c(
    uncoated =
        (mean(arr$CRT[arr$ManLu == "Arrow3"]) * sum(arr$ManLu == "Arrow3") +
         mean(arr$CRT[arr$ManLu == "Arrow5"]) * sum(arr$ManLu == "Arrow5")) /
        sum(arr$ManLu != "Arrow4"),
    coated = mean(arr$CRT[arr$ManLu == "Arrow4"])
), 2)

p.event.avg <-
    (mean(arr$CRT[arr$ManLu == "Arrow3"]) * sum(arr$ManLu == "Arrow3") +
     mean(arr$CRT[arr$ManLu == "Arrow4"]) * sum(arr$ManLu == "Arrow4") +
     mean(arr$CRT[arr$ManLu == "Arrow5"]) * sum(arr$ManLu == "Arrow5")) /
    nrow(arr)
## p.event.avg == 0.73

## minimal required sample size
#n.samplesize <- unname(ceiling(
#    n.events / (0.5 * p.event["uncoated"] + 0.5 * p.event["coated"])
#))
n.samplesize <- ceiling(n.events / p.event.assumed)

n.finalsamplesize <- signif(n.samplesize + 30, 2)

sample_size_tbl <- knitr::kable(
    cbind(delta, n.events, n.samplesize),
    row.names = FALSE,
    col.names = c("Delta HR", "Anzahl der Events", "Geschätzte Fallzahl"),
    caption = paste0(
        "Übersicht Fallzahlschätzung. ",
        "Unter der Annahme einer durchschnittlichen Wahrscheinlichkeit ",
        "an katheter-assoziierten Thrombosen von ", round(100 * p.event.assumed),
        " % notwendige Events für eine Power von ", round(100 * power),
        " % und einem Alpha-Fehler von ", round(100 * alpha),
        " %."
    )
)
