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



  ; Global Sine Wave
	gir 	ftgen	 123, 0, 8192, 10, 1

instr 1 
  
  kt init 0 
  av init 0

  gkslider2       chnget "gkslider2"
  gkslider3       chnget "gkslider3"
  gkslider4       chnget "gkslider4"
  gkslider5       chnget "gkslider5"
  gkslider6       chnget "gkslider6"
  gkslider7       chnget "gkslider7"

  ; Bytesong Generator
  gkslider1 chnget "gkslider1"
  aout = (kt*((kt>>10|kt>>8)&63&kt>>4*gkslider1)) & 255 
  aout = aout << 7 
  kt = kt+1 

  ; Filter 
  gkmooglpcutoff chnget "gkmooglpcutoff"  
  gkmooglpcutoff portk   gkmooglpcutoff, .05  
  gkmooglpres     chnget "gkmooglpres"
  gkmooglptoggle chnget "gkmooglptoggle" 
  if ($ON == gkmooglptoggle) then  
    aout Moogladder aout, gkmooglpcutoff, gkmooglpres  
    aout dcblock aout 
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
 
  ; Vibrato (Frequency Modulation)
  gkvibratotoggle chnget "gkvibratotoggle"
  gkvibratospeed  chnget "gkvibratospeed"
  gkvibratodepth  chnget "gkvibratodepth"     
  kvibrato  poscil3  gkvibratospeed,gkvibratodepth , gir 
  if ($ON == gkvibratotoggle) then
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
    atube warmth aout, gkdrive, gkblend
    aout balance atube, aout 
  endif

  ; Fuzz
  gktanhamount chnget "gktanhamount"
  gktanhtoggle chnget "gktanhtoggle"
  if ($ON == gktanhtoggle) then 
    atanh = tanh(aout*gktanhamount)
    aout balance atanh, aout 
  endif

  ; Safety

  aout butlp aout , 18000


  ; Statevar

  gkstatevarcutoff chnget "gkstatevarcutoff"
  gkstatevarres chnget "gkstatevarres"
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

  ; Reverb
  gkreverbamount  chnget "gkreverbamount"  
  gkreverbbrightness  chnget "gkreverbbrightness"  
  arev1, arev2 reverbsc aout,aout, gkreverbamount, gkreverbbrightness 


  outs aout + arev1, aout + arev2 

endin 

</CsInstruments> 
<CsScore> 
i1 0 36000 
</CsScore> 
</CsoundSynthesizer> 