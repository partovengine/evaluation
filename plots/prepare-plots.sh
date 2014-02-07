rm preparedplots/*.eps
rm preparedplots/*.pdf

./dj-bp-cdf-ES1.1.plot

./delay-ES2.1.1.plot
./delay-ES2.2.1.plot
./delay-ES2.3.1.plot

./jitter-ES2.1.1.plot
./jitter-ES2.2.1.plot
./jitter-ES2.3.1.plot

./cpu-ES2.1.1.plot
./cpu-ES2.2.1.plot
./wallclock-ES2.3.1.plot

./memory-ES2.1.1.plot
./memory-ES2.2.1.plot
./memory-ES2.3.1.plot

./dj-bp-cdf-ES3.1.plot

./delay-ES3.2.plot
./jitter-ES3.2.plot
./loss-ES3.2.plot
./cpu-ES3.2.plot
./memory-ES3.2.plot

ln ./dj-bp-cdf-ES1-1.eps preparedplots

ln ./delay-ES2-1-1.eps preparedplots
ln ./delay-ES2-2-1.eps preparedplots
ln ./delay-ES2-3-1.eps preparedplots

ln ./jitter-ES2-1-1.eps preparedplots
ln ./jitter-ES2-2-1.eps preparedplots
ln ./jitter-ES2-3-1.eps preparedplots

ln ./cpu-ES2-1-1.eps preparedplots
ln ./cpu-ES2-2-1.eps preparedplots
ln ./wallclock-ES2-3-1.eps preparedplots

ln ./memory-ES2-1-1.eps preparedplots
ln ./memory-ES2-2-1.eps preparedplots
ln ./memory-ES2-3-1.eps preparedplots

ln ./dj-bp-cdf-ES3-1.eps preparedplots

ln delay-ES3-2.eps preparedplots
ln jitter-ES3-2.eps preparedplots
ln loss-ES3-2.eps preparedplots
ln cpu-ES3-2.eps preparedplots
ln memory-ES3-2.eps preparedplots

cd preparedplots/
for epsfile in *.eps; do
	epstopdf $epsfile
done

