## Create the datasets shipped with gtstats.
##
## This script is for package development only. The saved .rda files in data/
## are the user-facing datasets. The synthetic datasets use fixed seeds so
## examples, tests, and teaching material remain reproducible.

utils::data("birthwt", package = "MASS", envir = environment())

birthwt <- MASS::birthwt
birthwt$low <- factor(
  birthwt$low, levels = c(0, 1),
  labels = c("Normal birth weight", "Low birth weight")
)
birthwt$race <- factor(
  birthwt$race, levels = c(1, 2, 3),
  labels = c("White", "Black", "Other")
)
birthwt$smoke <- factor(birthwt$smoke, levels = c(0, 1), labels = c("No", "Yes"))
birthwt$ht <- factor(birthwt$ht, levels = c(0, 1), labels = c("No", "Yes"))
birthwt$ui <- factor(birthwt$ui, levels = c(0, 1), labels = c("No", "Yes"))
birthwt$previous_preterm <- factor(
  ifelse(birthwt$ptl > 0, "Yes", "No"), levels = c("No", "Yes")
)
birthwt$antenatal_visits <- ordered(
  ifelse(birthwt$ftv == 0, "None", ifelse(birthwt$ftv == 1, "One", "Two or more")),
  levels = c("None", "One", "Two or more")
)

labels <- c(
  low = "Birth-weight outcome", age = "Maternal age (years)",
  lwt = "Maternal weight (lb)", race = "Maternal race",
  smoke = "Smoking during pregnancy", ptl = "Previous premature labours",
  ht = "Hypertension", ui = "Uterine irritability",
  ftv = "First-trimester visits", bwt = "Birth weight (g)",
  previous_preterm = "Previous premature labour",
  antenatal_visits = "First-trimester visits"
)
for (variable in names(labels)) attr(birthwt[[variable]], "label") <- labels[[variable]]

set.seed(20260804)
n_per_arm <- 60L
arm <- factor(rep(c("Usual care", "Treatment A", "Treatment B"), each = n_per_arm))
arm_effect <- rep(c(0, 2.4, 4.8), each = n_per_arm)
trial_data <- data.frame(
  id = seq_len(3L * n_per_arm),
  arm = arm,
  age = round(rnorm(3L * n_per_arm, mean = 58, sd = 11), 1),
  baseline_score = round(rnorm(3L * n_per_arm, mean = 52, sd = 10), 1),
  change_score = round(rnorm(3L * n_per_arm, mean = arm_effect, sd = 7), 1),
  hospital_days = round(rgamma(3L * n_per_arm, shape = 1.5, scale = rep(c(2.8, 2.1, 1.7), each = n_per_arm)), 1),
  biomarker_a = round(rnorm(3L * n_per_arm, 100, 15), 1),
  followup_years = round(runif(3L * n_per_arm, 0.75, 2), 2),
  stringsAsFactors = FALSE
)
trial_data$biomarker_b <- round(0.65 * trial_data$biomarker_a + rnorm(nrow(trial_data), 35, 12), 1)
trial_data$response <- ordered(
  sample(c("No response", "Partial response", "Complete response"), nrow(trial_data), replace = TRUE,
         prob = c(0.28, 0.44, 0.28)),
  levels = c("No response", "Partial response", "Complete response")
)
trial_data$adverse_event <- factor(
  rbinom(nrow(trial_data), 1, rep(c(0.35, 0.24, 0.16), each = n_per_arm)),
  levels = c(0, 1), labels = c("No", "Yes")
)
trial_data$rare_event <- factor(
  rbinom(nrow(trial_data), 1, rep(c(0.02, 0.03, 0.06), each = n_per_arm)),
  levels = c(0, 1), labels = c("No", "Yes")
)
trial_data$infection_events <- rpois(nrow(trial_data), lambda = trial_data$followup_years * rep(c(0.75, 0.55, 0.40), each = n_per_arm))

trial_labels <- c(
  id = "Participant ID", arm = "Treatment group", age = "Age (years)",
  baseline_score = "Baseline clinical score", change_score = "Change in clinical score",
  hospital_days = "Hospital stay (days)", biomarker_a = "Biomarker A",
  biomarker_b = "Biomarker B", response = "Clinical response",
  adverse_event = "Any adverse event", rare_event = "Rare adverse event",
  followup_years = "Follow-up (years)", infection_events = "Infection events"
)
for (variable in names(trial_labels)) attr(trial_data[[variable]], "label") <- trial_labels[[variable]]

set.seed(20260805)
n_pairs <- 90L
participant_effect <- rnorm(n_pairs, 0, 9)
pain_baseline <- rnorm(n_pairs, 60 + participant_effect, 8)
pain_followup <- rnorm(n_pairs, 54 + participant_effect, 8)
days_baseline <- rgamma(n_pairs, 2.2, 1.7)
# A deliberately right-skewed change distribution: this is used to teach why
# the automatic paired branch selects Wilcoxon signed-rank rather than t-test.
days_followup <- days_baseline + rgamma(n_pairs, 1.1, 1.4)
symptom_baseline <- rbinom(n_pairs, 1, 0.58)
symptom_followup <- rbinom(n_pairs, 1, 0.33)
paired_data <- data.frame(
  id = rep(seq_len(n_pairs), each = 2L),
  visit = factor(rep(c("Baseline", "Follow-up"), n_pairs), levels = c("Baseline", "Follow-up")),
  pain_score = round(as.vector(rbind(pain_baseline, pain_followup)), 1),
  days_off_work = as.vector(rbind(days_baseline, days_followup)),
  stringsAsFactors = FALSE
)
paired_data$symptom_present <- factor(
  as.vector(rbind(symptom_baseline, symptom_followup)),
  levels = c(0, 1), labels = c("No", "Yes")
)
paired_labels <- c(
  id = "Participant ID", visit = "Study visit", pain_score = "Pain score",
  days_off_work = "Days off work", symptom_present = "Symptom present"
)
for (variable in names(paired_labels)) attr(paired_data[[variable]], "label") <- paired_labels[[variable]]

dir.create("data", showWarnings = FALSE)
save(birthwt, file = "data/birthwt.rda", compress = "xz")
save(trial_data, file = "data/trial_data.rda", compress = "xz")
save(paired_data, file = "data/paired_data.rda", compress = "xz")
