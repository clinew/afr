TARGET=afr

default: pdf

dvi: ${TARGET}.tex
	latex ${TARGET}.tex
	latex $(TARGET).tex

ps: dvi
	dvips -R -Poutline -t letter ${TARGET}.dvi -o ${TARGET}.ps

pdf: ps
	ps2pdf ${TARGET}.ps
