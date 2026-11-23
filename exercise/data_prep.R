
## =============================================================================
## SASA 2026 Workshop: Interpretable Machine Learning
## November 2026
##
## Data preparation for the exercise "Interpretable machine learning (IML)"
##
## Downloads the public NHANES 2017-March 2020 pre-pandemic data from the CDC
## and creates the analysis dataset nhanes_hba1c.csv (adults 18+, complete
## cases). Only needs base R and the recommended package foreign.
##
## Marvin N. Wright
## Leibniz Institute for Prevention Research and Epidemiology - BIPS, Bremen
## =============================================================================

library(foreign)

# download and read one NHANES file (SAS transport format)
read_nhanes = function(file) {
  url = paste0("https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2017/DataFiles/",
               file, ".xpt")
  tmp = tempfile(fileext = ".xpt")
  download.file(url, tmp, mode = "wb", quiet = TRUE)
  read.xport(tmp)
}

demo = read_nhanes("P_DEMO")     # demographics
bmx = read_nhanes("P_BMX")       # body measures
ghb = read_nhanes("P_GHB")       # glycohemoglobin (HbA1c)
biopro = read_nhanes("P_BIOPRO") # standard biochemistry profile
tchol = read_nhanes("P_TCHOL")   # total cholesterol
hdl = read_nhanes("P_HDL")       # HDL cholesterol
smq = read_nhanes("P_SMQ")       # smoking questionnaire

# merge all files by participant ID
dat = Reduce(function(x, y) merge(x, y, by = "SEQN"), list(
  demo[, c("SEQN", "RIDAGEYR", "RIAGENDR", "RIDRETH3")],
  bmx[, c("SEQN", "BMXBMI")],
  ghb[, c("SEQN", "LBXGH")],
  biopro[, c("SEQN", "LBXSGL", "LBXSCR")],
  tchol[, c("SEQN", "LBXTC")],
  hdl[, c("SEQN", "LBDHDD")],
  smq[, c("SEQN", "SMQ020", "SMQ040")]
))

# adults only (smoking questions are asked from age 18)
dat = dat[dat$RIDAGEYR >= 18, ]

female = dat$RIAGENDR == 2

# eGFR from serum creatinine, CKD-EPI 2021 equation (without race)
kappa = ifelse(female, 0.7, 0.9)
alpha = ifelse(female, -0.241, -0.302)
egfr = 142 * pmin(dat$LBXSCR / kappa, 1)^alpha *
  pmax(dat$LBXSCR / kappa, 1)^(-1.2) * 0.9938^dat$RIDAGEYR *
  ifelse(female, 1.012, 1)

# smoking status: never (< 100 cigarettes in life), former, current
smoking = ifelse(dat$SMQ020 == 2, "never",
                 ifelse(dat$SMQ040 == 3, "former",
                        ifelse(dat$SMQ040 %in% 1:2, "current", NA)))

# final dataset with readable names
nhanes = data.frame(
  SEQN = dat$SEQN,
  glycohemoglobin = dat$LBXGH,
  age = dat$RIDAGEYR,
  gender = ifelse(female, "female", "male"),
  ancestry = factor(dat$RIDRETH3, levels = c(1, 2, 3, 4, 6, 7), labels = c(
    "Mexican American", "Other Hispanic", "Non-Hispanic White",
    "Non-Hispanic Black", "Non-Hispanic Asian", "Other/Multiracial")),
  bmi = dat$BMXBMI,
  glucose = dat$LBXSGL,
  egfr = round(egfr, 1),
  total_cholesterol = dat$LBXTC,
  non_hdl = dat$LBXTC - dat$LBDHDD,
  smoking = smoking
)
nhanes = na.omit(nhanes)

# save in the working directory (should be the exercise folder)
write.csv(nhanes, "nhanes_hba1c.csv", row.names = FALSE)
