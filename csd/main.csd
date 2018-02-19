<CsoundSynthesizer>
  <CsOptions>
  </CsOptions>
<CsInstruments>
sr     = 44100
ksmps  = 1
nchnls = 2

#include 'pitchshifter.csd'
#include 'moogladder.csd'
#include 'vowel.csd'
#include 'vowelenum.csd'
#include 'taptube.csd'
#include 'ensemble.csd'
#include 'statevar.csd'
#include 'statevarenum.csd'


#define ON #1#
#define OFF #0#

gadelayout init 0

  ; Global Sine Wave
	gir 	ftgen	 123, 0, 8192, 10, 1

instr 1

 ain inch 1

  kt init 0
  av init 0

  gkincrement     chnget "gkincrement"
  gkslider3       chnget "gkslider3"
  gkslider4       chnget "gkslider4"
  gkslider5       chnget "gkslider5"
  gkslider6       chnget "gkslider6"
  gkslider7       chnget "gkslider7"

  ; Bytesong Generator
  gkbyte1 chnget "gkbyte1"
  gkbyte1  portk   gkbyte1, 0.100
  gkbyte2 chnget "gkbyte2"
  gkbyte2  portk   gkbyte2, 0.100
  gkbyte3 chnget "gkbyte3"
  gkbyte3  portk   gkbyte3, 0.100
  aout = (kt*((kt>>10|kt>>8)&gkbyte2&kt>>4*gkbyte1)) & gkbyte3
  aout = aout << 7
  aout dcblock2 aout

  ;aout = ain * aout
  kt = kt+gkincrement

  ; Filter
  gkmooglpcutoff  chnget "gkmooglpcutoff"
  gkmooglpcutoff  portk   gkmooglpcutoff, .05
  gkmooglpres     chnget "gkmooglpres"
  gkmooglptoggle  chnget "gkmooglptoggle"
  if ($ON == gkmooglptoggle) then
    aout Moogladder aout, gkmooglpcutoff, gkmooglpres
    aout dcblock2 aout
  endif

  ; Fuzz
  gktanhamount chnget "gktanhamount"
  gktanhtoggle chnget "gktanhtoggle"
  if ($ON == gktanhtoggle) then
    atanh = tanh(aout*gktanhamount)
    atanh dcblock2 atanh
    aout balance atanh, aout
  endif

  ; Moog LFO
  gkmooglplfocenter chnget "gkmooglplfocenter"
  gkmooglplfodepth  chnget "gkmooglplfodepth"
  gkmooglplfospeed  chnget "gkmooglplfospeed"
  gkmooglplfores    chnget "gkmooglplfores"
  gkmooglplfotoggle chnget "gkmooglplfotoggle"
  if ($ON == gkmooglplfotoggle) then
    kmooglfo  poscil3  gkmooglplfodepth,gkmooglplfospeed , gir
    kmooglplfofreq = gkmooglplfocenter + kmooglfo
        if (kmooglplfofreq > 19000) then
            kmooglplfofreq = 19000
    elseif (kmooglplfofreq < 40) then
            kmooglplfofreq = 40
    endif
    aout Moogladder aout,kmooglplfofreq , gkmooglplfores
    aout dcblock2 aout
  endif


  ; Tremolo (Amplitude Modulation)
  gktremdepth     chnget "gktremdepth"
  gktremspeed     chnget "gktremspeed"
	alfo 	poscil3	 gktremdepth,gktremspeed , gir
  alfo = alfo*2 + 1
  aout = aout *alfo

  ; Pitch Shift
  gkpitchshift chnget "gkpitchshift"
  aout freqShift aout, gkpitchshift
  aout dcblock2 aout

  ; Vibrato (Frequency Modulation)
  gkvibratotoggle chnget "gkvibratotoggle"
  gkvibratospeed  chnget "gkvibratospeed"
  gkvibratodepth  chnget "gkvibratodepth"
  if ($ON == gkvibratotoggle) then
      kvibrato  poscil3  gkvibratospeed,gkvibratodepth , gir
      aout freqShift aout, kvibrato
  endif

  ; Format Filter
  gkvoweltoggle chnget "gkvoweltoggle"
  gkvowel       chnget "gkvowel"
  gkmode        chnget "gkmode"
  if ($ON == gkvoweltoggle) then
    if ($BASS == gkmode) then
      avowel  vowel aout, gkvowel, $BASS
      aout balance avowel, aout
    elseif ($TENOR == gkmode) then
      avowel  vowel aout, gkvowel, $TENOR
      aout balance avowel, aout
    elseif ($COUNTERTENOR == gkmode) then
      avowel  vowel aout, gkvowel, $COUNTERTENOR
      aout balance avowel, aout
    elseif ($ALTO == gkmode) then
      avowel  vowel aout, gkvowel, $ALTO
      aout balance avowel, aout
    elseif ($SOPRANO == gkmode) then
      avowel  vowel aout, gkvowel, $SOPRANO
      aout balance avowel, aout
    endif
  endif

  ; Tube Warmth
  gktubetoggle     chnget "gktubetoggle"
  gkdrive          chnget "gkdrive"
  gkblend          chnget "gkblend"
  if ($ON == gktubetoggle) then
    aout dcblock2 aout
    atube warmth aout, gkdrive, gkblend
    aout dcblock2 aout
    atube dcblock2 atube
    aout balance atube, aout
  endif

  ; Safety
  aout butlp aout , 20000

  ; Statevar
  gkstatevarcutoff chnget "gkstatevarcutoff"
  gkstatevarres    chnget "gkstatevarres"
  gkstatevartoggle chnget "gkstatevartoggle"
  gkstatevartype   chnget "gkstatevartype"
  if ($ON == gkstatevartoggle) then
    ahp,alp,abp,abr   Statevar  aout , gkstatevarcutoff, gkstatevarres
    if ($LOWPASS == gkstatevartype) then
     aout = alp
    elseif ($HIGHPASS == gkstatevartype) then
     aout = ahp
    elseif ($BANDPASS == gkstatevartype) then
     aout = abp
    elseif ($BANDREJECT == gkstatevartype) then
     aout = abr
    endif
  endif


  gkdelaytoggle chnget "gkdelaytoggle"
  if ($ON == gkdelaytoggle) then
    gkdelayfeedback chnget "gkdelayfeedback"
    gkdelaytime chnget "gkdelaytime"
    gkdelayfilter chnget "gkdelayfilter"
    adelayin = (gadelayout * 0.9999) * gkdelayfeedback + aout
    gadelayout vdelay3 adelayin, gkdelaytime *1000, 4000
    gadelayout moogladder gadelayout, gkdelayfilter, .1
    aout = aout *.5 + gadelayout *.5
  endif


  ; Reverb
  gkreverbamount      chnget "gkreverbamount"
  gkreverbbrightness  chnget "gkreverbbrightness"
  aout dcblock2 aout
  arev1, arev2 reverbsc aout,aout, gkreverbamount, gkreverbbrightness

  outs aout + arev1, aout + arev2
endin
</CsInstruments>
<CsScore>
i1 0 36000
</CsScore>
</CsoundSynthesizer>