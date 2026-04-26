# Social Science Bibliometric Analysis (Section 5.1 to 5.26)
# ------------------------------------------------------------------
# This script generates tables and advanced figures for bibliometric analysis.
# Input files should be placed in ./data and outputs are saved in ./outputs.

required_packages <- c(
  "tidyverse", "lubridate", "forecast", "broom", "scales", "patchwork",
  "igraph", "ggraph", "tidygraph", "wordcloud", "RColorBrewer", "ggrepel"
)

missing_pkgs <- required_packages[!sapply(required_packages, requireNamespace, quietly = TRUE)]
if (length(missing_pkgs) > 0) {
  message("Install missing packages before running: ", paste(missing_pkgs, collapse = ", "))
}

suppressPackageStartupMessages({
  library(tidyverse)
  library(forecast)
  library(broom)
  library(scales)
  library(patchwork)
  library(igraph)
  library(ggraph)
  library(tidygraph)
  library(wordcloud)
  library(RColorBrewer)
  library(ggrepel)
})

# -------------------------- Paths ---------------------------------
dir.create("outputs", showWarnings = FALSE)
dir.create("outputs/figures", showWarnings = FALSE, recursive = TRUE)
dir.create("outputs/tables", showWarnings = FALSE, recursive = TRUE)

# -------------------------- Input ---------------------------------
# Minimum expected file structure:
# data/yearly_metrics.csv: year, publications, citations, single_authored, multi_authored
# data/doc_types.csv: document_type, count
# data/authors.csv: author, publications, citations, h_index
# data/sources.csv: source, article_count
# data/institutions.csv: institution, article_count
# data/countries.csv: country, publications, citations
# data/keywords.csv: keyword, occurrences
# data/collaboration_edges.csv: from, to, weight

read_or_stop <- function(path) {
  if (!file.exists(path)) stop("Missing required file: ", path)
  readr::read_csv(path, show_col_types = FALSE)
}

yearly <- read_or_stop("data/yearly_metrics.csv") %>%
  arrange(year) %>%
  mutate(
    cumulative_publications = cumsum(publications),
    acpp = citations / publications,
    exp_growth_rate = publications / lag(publications),
    ln_cp = log(cumulative_publications),
    rgr = (ln_cp - lag(ln_cp)) / (year - lag(year)),
    dt = log(2) / rgr,
    degree_collaboration = 1 - (single_authored / publications)
  )

# -------------------- 5.2 Growth of Publication -------------------
table1 <- yearly %>%
  summarise(
    total_years = n(),
    total_publications = sum(publications),
    total_citations = sum(citations),
    mean_publications = mean(publications),
    median_publications = median(publications),
    max_publications = max(publications),
    min_publications = min(publications)
  )
write_csv(table1, "outputs/tables/table1_overall_summary.csv")

fig1 <- ggplot(yearly, aes(x = year, y = publications)) +
  geom_col(fill = "#3E79B7", alpha = 0.85) +
  geom_line(aes(y = cumulative_publications / 10), color = "#D94801", linewidth = 1.2) +
  scale_y_continuous(labels = comma) +
  labs(
    title = "Figure 1: Overall Summary of Publications on Social Science",
    subtitle = "Bars: Annual publications | Line: Scaled cumulative publications",
    x = "Year", y = "Publications"
  ) +
  theme_minimal(base_size = 12)
ggsave("outputs/figures/figure1_overall_summary.png", fig1, width = 11, height = 6, dpi = 300)

# ------------- 5.3 Annual Scientific Publication Growth -----------
table2 <- yearly %>%
  transmute(
    year,
    publications,
    annual_increment = publications - lag(publications),
    annual_growth_percent = (publications - lag(publications)) / lag(publications) * 100
  )
write_csv(table2, "outputs/tables/table2_growth_research_output.csv")

fig2 <- ggplot(table2, aes(year, annual_growth_percent)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  geom_col(fill = "#2A9D8F") +
  geom_smooth(method = "loess", se = FALSE, color = "#264653", linewidth = 1) +
  labs(
    title = "Figure 2: Growth of Research Output",
    x = "Year", y = "Annual Growth (%)"
  ) +
  theme_light(base_size = 12)
ggsave("outputs/figures/figure2_growth_output.png", fig2, width = 11, height = 6, dpi = 300)

# ----------- 5.4 Future trend using straight line trend -----------
trend_params <- tibble(
  sum_x = 0,
  sum_y = 5942,
  sum_x2 = 5738,
  sum_xy = 93946,
  n = 40,
  a = 5942 / 40,
  b = 93946 / 5738,
  x_2026 = 2026 - 2005,
  y_2026 = (5942 / 40) + (93946 / 5738) * (2026 - 2005)
)
write_csv(trend_params, "outputs/tables/table3_time_series_trend_parameters.csv")

# forecast from observed data as a consistency check
pub_ts <- ts(yearly$publications, start = min(yearly$year), frequency = 1)
fit_arima <- auto.arima(pub_ts)
fc <- forecast(fit_arima, h = 5)

table3 <- as_tibble(data.frame(
  year = seq(max(yearly$year) + 1, by = 1, length.out = 5),
  forecast_publications = as.numeric(fc$mean),
  lower_95 = as.numeric(fc$lower[, 2]),
  upper_95 = as.numeric(fc$upper[, 2])
))
write_csv(table3, "outputs/tables/table3_time_series_forecast.csv")

fig3 <- autoplot(fc) +
  autolayer(pub_ts, series = "Observed") +
  labs(
    title = "Figure 3: Time Series Analysis of Annual Research Publications",
    x = "Year", y = "Publications"
  ) +
  theme_minimal(base_size = 12)
ggsave("outputs/figures/figure3_time_series.png", fig3, width = 11, height = 6, dpi = 300)

# ----------------- 5.5 Exponential Growth Rate --------------------
table4 <- yearly %>%
  select(year, publications, exp_growth_rate)
write_csv(table4, "outputs/tables/table4_exponential_growth.csv")

fig4 <- ggplot(table4, aes(year, exp_growth_rate)) +
  geom_line(color = "#7B2CBF", linewidth = 1) +
  geom_point(size = 2.2, color = "#5A189A") +
  geom_smooth(method = "lm", se = FALSE, linetype = "dashed", color = "#240046") +
  labs(
    title = "Figure 4: Exponential Growth of Research Publication",
    y = "EGR = Nt / Nt-1", x = "Year"
  ) +
  theme_bw(base_size = 12)
ggsave("outputs/figures/figure4_egr.png", fig4, width = 11, height = 6, dpi = 300)

# -------- 5.6 Relative Growth Rate (RGR) and Doubling Time --------
table5 <- yearly %>%
  select(year, publications, cumulative_publications, rgr, dt)
write_csv(table5, "outputs/tables/table5_rgr_dt.csv")

fig5a <- ggplot(table5, aes(year, rgr)) +
  geom_line(color = "#1D3557", linewidth = 1) + geom_point(color = "#457B9D") +
  labs(title = "RGR Trend", x = "Year", y = "RGR") + theme_minimal()
fig5b <- ggplot(table5, aes(year, dt)) +
  geom_line(color = "#E63946", linewidth = 1) + geom_point(color = "#D62828") +
  labs(title = "Doubling Time Trend", x = "Year", y = "DT") + theme_minimal()
fig5 <- fig5a + fig5b + plot_annotation(title = "Figure 5: Relative Growth Rate and Doubling Time")
ggsave("outputs/figures/figure5_rgr_dt.png", fig5, width = 12, height = 6, dpi = 300)

# -------------------- 5.7 Document Types --------------------------
doc_types <- read_or_stop("data/doc_types.csv")
write_csv(doc_types, "outputs/tables/table6_document_types.csv")
fig6 <- ggplot(doc_types, aes(reorder(document_type, count), count, fill = count)) +
  geom_col() + coord_flip() +
  scale_fill_viridis_c() +
  labs(title = "Figure 6: Documents by Type of Publications", x = "Document Type", y = "Count") +
  theme_minimal()
ggsave("outputs/figures/figure6_document_types.png", fig6, width = 10, height = 7, dpi = 300)

# ---------------- 5.8 Output and Citation patterns ----------------
table7 <- yearly %>% select(year, RO = publications, TC = citations, ACPP = acpp)
write_csv(table7, "outputs/tables/table7_output_citations.csv")
fig7 <- ggplot(table7, aes(year)) +
  geom_line(aes(y = RO, color = "NP"), linewidth = 1.1) +
  geom_line(aes(y = TC / 10, color = "TC (scaled)"), linewidth = 1.1) +
  scale_color_manual(values = c("NP" = "#2A9D8F", "TC (scaled)" = "#E76F51")) +
  labs(title = "Figure 7: Year-wise Citation Pattern (NP & TC)", y = "Count") + theme_minimal()
fig8 <- ggplot(table7, aes(year, ACPP)) + geom_col(fill = "#264653") +
  labs(title = "Figure 8: Average Citation per Year (ACPP)", y = "ACPP") + theme_light()
ggsave("outputs/figures/figure7_np_tc.png", fig7, width = 11, height = 6, dpi = 300)
ggsave("outputs/figures/figure8_acpp.png", fig8, width = 11, height = 6, dpi = 300)

# ---------------- 5.9 & 5.10 Collaboration trend ------------------
table8 <- yearly %>% select(year, single_authored, multi_authored, publications)
write_csv(table8, "outputs/tables/table8_authorship_pattern.csv")

fig9 <- table8 %>%
  pivot_longer(cols = c(single_authored, multi_authored), names_to = "authorship", values_to = "count") %>%
  ggplot(aes(year, count, fill = authorship)) +
  geom_area(alpha = 0.65, position = "stack") +
  labs(title = "Figure 9: Distribution of Publication as per Authorship Pattern", y = "Count") +
  theme_minimal()
ggsave("outputs/figures/figure9_authorship_pattern.png", fig9, width = 11, height = 6, dpi = 300)

table9 <- yearly %>% select(year, single_authored, publications, degree_collaboration)
write_csv(table9, "outputs/tables/table9_degree_collaboration.csv")
fig10 <- ggplot(table9, aes(year, degree_collaboration)) +
  geom_line(color = "#003049", linewidth = 1.2) + geom_point(color = "#D62828") +
  scale_y_continuous(labels = number_format(accuracy = 0.01)) +
  labs(title = "Figure 10: Degree of Collaboration (DC)", y = "DC") +
  theme_bw()
ggsave("outputs/figures/figure10_dc.png", fig10, width = 11, height = 6, dpi = 300)

# -------------------- 5.11 Prolific authors -----------------------
authors <- read_or_stop("data/authors.csv")

table10 <- authors %>% arrange(desc(publications)) %>% slice_head(n = 20)
write_csv(table10, "outputs/tables/table10_top_authors_publications.csv")
fig11 <- ggplot(table10, aes(reorder(author, publications), publications)) +
  geom_col(fill = "#005F73") + coord_flip() +
  labs(title = "Figure 11: Highly Productive Authors by Publications", x = "Author", y = "Publications") +
  theme_minimal()
ggsave("outputs/figures/figure11_authors_publications.png", fig11, width = 10, height = 8, dpi = 300)

table11 <- authors %>% arrange(desc(citations)) %>% slice_head(n = 20)
write_csv(table11, "outputs/tables/table11_top_authors_citations.csv")
fig12 <- ggplot(table11, aes(reorder(author, citations), citations)) +
  geom_col(fill = "#9B2226") + coord_flip() +
  labs(title = "Figure 12: Highly Productive Authors by Citations", x = "Author", y = "Citations") +
  theme_minimal()
ggsave("outputs/figures/figure12_authors_citations.png", fig12, width = 10, height = 8, dpi = 300)

table12 <- authors %>% arrange(desc(h_index)) %>% slice_head(n = 20)
write_csv(table12, "outputs/tables/table12_top_authors_hindex.csv")
fig13 <- ggplot(table12, aes(reorder(author, h_index), h_index)) +
  geom_col(fill = "#EE9B00") + coord_flip() +
  labs(title = "Figure 13: Highly Productive Authors by H-index", x = "Author", y = "H-index") +
  theme_minimal()
ggsave("outputs/figures/figure13_authors_hindex.png", fig13, width = 10, height = 8, dpi = 300)

# -------------------- 5.12 Sources, 5.13 Institutions -------------
sources <- read_or_stop("data/sources.csv")
inst <- read_or_stop("data/institutions.csv")

table13 <- sources %>% arrange(desc(article_count)) %>% slice_head(n = 20)
write_csv(table13, "outputs/tables/table13_top_sources.csv")
fig14 <- ggplot(table13, aes(reorder(source, article_count), article_count)) +
  geom_col(fill = "#0A9396") + coord_flip() +
  labs(title = "Figure 14: Top 20 Publication Sources by Article Count", x = "Source", y = "Articles") +
  theme_minimal()
ggsave("outputs/figures/figure14_top_sources.png", fig14, width = 11, height = 8, dpi = 300)

table14 <- inst %>% arrange(desc(article_count)) %>% slice_head(n = 20)
write_csv(table14, "outputs/tables/table14_top_institutions.csv")
fig15 <- ggplot(table14, aes(reorder(institution, article_count), article_count)) +
  geom_col(fill = "#BB3E03") + coord_flip() +
  labs(title = "Figure 15: Top 20 Institution Affiliations by Article Count", x = "Institution", y = "Articles") +
  theme_minimal()
ggsave("outputs/figures/figure15_top_institutions.png", fig15, width = 11, height = 8, dpi = 300)

# -------------------- 5.15 Country-wise output --------------------
countries <- read_or_stop("data/countries.csv")
table16 <- countries %>% arrange(desc(publications))
write_csv(table16, "outputs/tables/table16_country_output_citation.csv")
fig17 <- ggplot(table16, aes(publications, citations, size = citations, label = country, color = publications)) +
  geom_point(alpha = 0.8) + geom_text_repel(size = 3, max.overlaps = 20) +
  scale_color_viridis_c() +
  labs(title = "Figure 17: Country-wise Publication and Citation Impact", x = "Publications", y = "Citations") +
  theme_minimal()
ggsave("outputs/figures/figure17_country_output_citation.png", fig17, width = 11, height = 7, dpi = 300)

# -------------------- 5.16 Keywords + 5.17 wordcloud -------------
keywords <- read_or_stop("data/keywords.csv")

# Figure 18: Keywords network map (co-occurrence approximated with shared frequency)
kw_top <- keywords %>% arrange(desc(occurrences)) %>% slice_head(n = 50)
kw_pairs <- tidyr::crossing(k1 = kw_top$keyword, k2 = kw_top$keyword) %>%
  filter(k1 < k2) %>%
  left_join(kw_top %>% select(k1 = keyword, o1 = occurrences), by = "k1") %>%
  left_join(kw_top %>% select(k2 = keyword, o2 = occurrences), by = "k2") %>%
  mutate(weight = pmin(o1, o2)) %>%
  filter(weight >= quantile(weight, 0.75))

kw_graph <- graph_from_data_frame(kw_pairs %>% select(from = k1, to = k2, weight), directed = FALSE)
fig18 <- ggraph(kw_graph, layout = "fr") +
  geom_edge_link(aes(width = weight), alpha = 0.2, show.legend = FALSE) +
  geom_node_point(color = "#1D3557", size = 3) +
  geom_node_text(aes(label = name), repel = TRUE, size = 2.8) +
  theme_void() + labs(title = "Figure 18: Keywords Network Map")
ggsave("outputs/figures/figure18_keywords_network.png", fig18, width = 11, height = 8, dpi = 300)

png("outputs/figures/figure19_wordcloud.png", width = 1400, height = 1000, res = 150)
wordcloud(
  words = keywords$keyword,
  freq = keywords$occurrences,
  scale = c(6, 0.8),
  max.words = 200,
  colors = brewer.pal(8, "Dark2"),
  random.order = FALSE
)
title("Figure 19: Word Cloud")
dev.off()

# ---------------- 5.19 Author collaboration network ---------------
collab <- read_or_stop("data/collaboration_edges.csv")
collab_graph <- graph_from_data_frame(collab, directed = FALSE)

nodes_summary <- tibble(
  Nodes = gorder(collab_graph),
  Edges = gsize(collab_graph),
  Network_Density = edge_density(collab_graph),
  Clusters = components(collab_graph)$no,
  Mean_Degree = mean(degree(collab_graph)),
  Mean_Betweenness = mean(betweenness(collab_graph))
)
write_csv(nodes_summary, "outputs/tables/network_summary_author_collaboration.csv")

fig21 <- ggraph(collab_graph, layout = "fr") +
  geom_edge_link(aes(width = weight), alpha = 0.2, color = "grey45", show.legend = FALSE) +
  geom_node_point(aes(size = degree(collab_graph)), color = "#2A9D8F") +
  geom_node_text(aes(label = name), repel = TRUE, size = 2.6) +
  theme_void() + labs(title = "Figure 21: Author Collaboration Network")
ggsave("outputs/figures/figure21_author_collaboration_network.png", fig21, width = 12, height = 9, dpi = 300)

# ------------------- 5.21 Bradford's law --------------------------
table17 <- tribble(
  ~Zone, ~RCS, ~CRCS, ~rate_journals_pct, ~RP, ~CRP, ~rate_articles_pct, ~bradford_multiplier,
  "Zone 1", 1, 1, 0.56, 2084, 2084, 35.07, NA,
  "Zone 2", 11, 12, 6.15, 1914, 3998, 32.21, 11,
  "Zone 3", 167, 179, 93.86, 1944, 5942, 32.72, 15.18,
  "Total", 179, 179, 100, 5942, 5942, 100, 13.09
)
write_csv(table17, "outputs/tables/table17_bradford_law.csv")

fig23 <- ggplot(table17 %>% filter(Zone != "Total"), aes(Zone, RP, fill = Zone)) +
  geom_col(width = 0.65) +
  geom_text(aes(label = scales::percent(rate_articles_pct / 100, accuracy = 0.01)), vjust = -0.4) +
  labs(title = "Figure 23: Bradford's Law of Distribution", y = "Research Publications") +
  theme_minimal() + theme(legend.position = "none")
ggsave("outputs/figures/figure23_bradford_distribution.png", fig23, width = 9, height = 6, dpi = 300)

# ------------------- 5.22 Lotka's law -----------------------------
productivity <- authors %>% count(publications, name = "observed_authors")
C <- productivity$observed_authors[productivity$publications == 1]
if (length(C) == 0) C <- max(productivity$observed_authors)
n_exp <- 2
lotka <- productivity %>% mutate(expected_authors = C / (publications^n_exp))

fig24 <- ggplot(lotka, aes(publications)) +
  geom_point(aes(y = observed_authors, color = "Observed"), size = 2) +
  geom_line(aes(y = observed_authors, color = "Observed"), linewidth = 1) +
  geom_line(aes(y = expected_authors, color = "Lotka Expected"), linewidth = 1.1, linetype = "dashed") +
  scale_x_log10() + scale_y_log10() +
  scale_color_manual(values = c("Observed" = "#005F73", "Lotka Expected" = "#AE2012")) +
  labs(title = "Figure 24: Author Productivity as per Lotka's Law",
       x = "Publications (log scale)", y = "Number of Authors (log scale)") +
  theme_minimal()
ggsave("outputs/figures/figure24_lotka_law.png", fig24, width = 10, height = 7, dpi = 300)

# ------------------- 5.26 Hypothesis testing ----------------------
# H1: Exponential growth significance (trend in annual publications)
model_growth <- lm(publications ~ year, data = yearly)
# H2: Productivity differences among authors
anova_prod <- aov(publications ~ cut(citations, breaks = quantile(citations, probs = seq(0, 1, 0.25), na.rm = TRUE), include.lowest = TRUE), data = authors)
# H3: International collaboration proxy (whether multi-authored dominates)
collab_test <- t.test(yearly$multi_authored, yearly$single_authored, paired = TRUE)
# H4: Differences among author outputs and source productivity
kruskal_auth <- kruskal.test(publications ~ 1, data = authors)
kruskal_source <- kruskal.test(article_count ~ 1, data = sources)

hypothesis_results <- list(
  h1_growth_model = tidy(model_growth),
  h2_anova = tidy(anova_prod),
  h3_collaboration_t = tidy(collab_test),
  h4_author_kruskal = tidy(kruskal_auth),
  h4_source_kruskal = tidy(kruskal_source)
)

write_csv(hypothesis_results$h1_growth_model, "outputs/tables/hypothesis_h1_growth_model.csv")
write_csv(hypothesis_results$h2_anova, "outputs/tables/hypothesis_h2_author_productivity_anova.csv")
write_csv(hypothesis_results$h3_collaboration_t, "outputs/tables/hypothesis_h3_collab_ttest.csv")
write_csv(hypothesis_results$h4_author_kruskal, "outputs/tables/hypothesis_h4_author_kruskal.csv")
write_csv(hypothesis_results$h4_source_kruskal, "outputs/tables/hypothesis_h4_source_kruskal.csv")

message("All requested tables and figures have been generated in ./outputs")
