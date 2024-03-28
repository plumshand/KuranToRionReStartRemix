
PROJ = KuranToRionReStart
TARGET = $(PROJ).nes
OBJFILES = header.o \
		crt0.o \
		main.o \
		title.o \
		vars.o \
		drawing.o \
		gaming.o \
		ReStartRemix.o

LIBFILES = NSD.lib

CFGFILE = memory.cfg

AS = ca65.exe
ASFLAGS = -t none -g

LINKER = ld65.exe
LDFLAGS = --dbgfile $(PROJ).dbg

NSC = nsc64.exe

RM = del

.PHONY: all clean

all: $(TARGET)

$(TARGET): $(OBJFILES) $(LIBFILES) $(CFGFILE)
	$(LINKER) --config $(CFGFILE) $(LDFLAGS) $(OBJFILES) $(LIBFILES) -o $@

%.o: %.s includes.inc nes.inc nsd.inc nsddef.inc structs.inc
	$(AS) $(ASFLAGS) $< -o $@

crt0.o: palette.inc bgchars.chr sprites.chr

ReStartRemix.s: ReStartRemix.mml
	$(NSC) -a $<

clean:
	$(RM) *.o ReStartRemix.s *.dbg $(TARGET)
