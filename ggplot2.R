## Load the ggplot2 package
library(ggplot2)

# Plot base
plt_mpg_vs_fcyl_by_fam <- ggplot(mtcars, aes(fcyl, mpg, color = fam))

# Default points are shown for comparison
plt_mpg_vs_fcyl_by_fam + geom_point()

# Now jitter and dodge the point positions
plt_mpg_vs_fcyl_by_fam + geom_point(position = position_jitterdodge(jitter.width = 0.3, dodge.width =0.3))

# Change the command below so that cyl is treated as factor
ggplot(mtcars, aes(factor(cyl), mpg)) + geom_point()

# Change the color aesthetic to a size aesthetic
ggplot(mtcars, aes(wt, mpg, color = disp)) +
  geom_point()
ggplot(mtcars, aes(wt, mpg, size = disp)) +
  geom_point()