#
ifelse(PLATFORM, `glk', `# Topology for GeminiLake with Dialog7219+Maxim98357a.', `')
ifelse(PLATFORM, `cml', `# Topology for CometLake with Dialog7219+Maxim98357a.', `')
#

# Include topology builder
include(`utils.m4')
include(`dai.m4')
include(`pipeline.m4')
include(`ssp.m4')
include(`hda.m4')

# Include TLV library
include(`common/tlv.m4')

# Include Token library
include(`sof/tokens.m4')

# include platform specific dsp configuration and machine specific settings
include(`platform/intel/'PLATFORM`-da7219.m4')

DEBUG_START

define(KWD_PIPE_SCH_DEADLINE_US, 20000)

#
# Define the pipelines
#
# PCM0  ----> volume (pipe 1)   -----> SSP1 (speaker - maxim98357a, BE link 0)
# PCM1  <---> volume (pipe 2,3) <----> SSP(SSP_INDEX) (headset - dailog7219, BE link 1)
# PCM(DMIC_PCM_NUM) <---- DMIC0 (dmic capture, BE link 2)
# PCM5  ----> volume (pipe 5)   -----> iDisp1 (HDMI/DP playback, BE link 3)
# PCM6  ----> volume (pipe 6)   -----> iDisp2 (HDMI/DP playback, BE link 4)
# PCM7  ----> volume (pipe 7)   -----> iDisp3 (HDMI/DP playback, BE link 5)
# PCM8  <-------(pipe 8) <------------+- KPBM 0 <----- DMIC1 (dmic16k, BE link 6)
#                                     |
# Detector <--- selector (pipe 9) <---+
#

dnl PIPELINE_PCM_ADD(pipeline,
dnl     pipe id, pcm, max channels, format,
dnl     period, priority, core,
dnl     pcm_min_rate, pcm_max_rate, pipeline_rate,
dnl     time_domain, sched_comp)

# Low Latency playback pipeline 1 on PCM 0 using max 2 channels of s32le.
# Set 1000us deadline on core 0 with priority 0
PIPELINE_PCM_ADD(PIPE_VOLUME_PLAYBACK,
	1, 0, 2, s32le,
	1000, 0, 0,
	48000, 48000, 48000)

# Low Latency playback pipeline 2 on PCM 1 using max 2 channels of s32le.
# Set 1000us deadline on core 0 with priority 0
PIPELINE_PCM_ADD(sof/pipe-volume-playback.m4,
	2, 1, 2, s32le,
	1000, 0, 0,
	48000, 48000, 48000)

# Low Latency capture pipeline 3 on PCM 1 using max 2 channels of s32le.
# Set 1000us deadline on core 0 with priority 0
PIPELINE_PCM_ADD(sof/pipe-volume-capture.m4,
	3, 1, 2, s32le,
	1000, 0, 0,
	48000, 48000, 48000)

# Low Latency playback pipeline 5 on PCM 5 using max 2 channels of s32le.
# Set 1000us deadline on core 0 with priority 0
PIPELINE_PCM_ADD(sof/pipe-volume-playback.m4,
        5, 5, 2, s32le,
        1000, 0, 0,
	48000, 48000, 48000)

# Low Latency playback pipeline 6 on PCM 6 using max 2 channels of s32le.
# Set 1000us deadline on core 0 with priority 0
PIPELINE_PCM_ADD(sof/pipe-volume-playback.m4,
        6, 6, 2, s32le,
        1000, 0, 0,
	48000, 48000, 48000)

# Low Latency playback pipeline 7 on PCM 7 using max 2 channels of s32le.
# Set 1000us deadline on core 0 with priority 0
PIPELINE_PCM_ADD(sof/pipe-volume-playback.m4,
        7, 7, 2, s32le,
        1000, 0, 0,
	48000, 48000, 48000)

#
# DAIs configuration
#

dnl DAI_ADD(pipeline,
dnl     pipe id, dai type, dai_index, dai_be,
dnl     buffer, periods, format,
dnl     deadline, priority, core, time_domain)

# playback DAI is SSP1 using 2 periods
# Buffers use s16le format, 1000us deadline on core 0 with priority 0
DAI_ADD(sof/pipe-dai-playback.m4,
	1, SSP, 1, SSP1-Codec,
	PIPELINE_SOURCE_1, 2, SSP1_VALID_BITS_STR,
	1000, 0, 0, SCHEDULE_TIME_DOMAIN_TIMER)

# playback DAI is SSP(SSP_INDEX) using 2 periods
# Buffers use s16le format, 1000us deadline on core 0 with priority 0
DAI_ADD(sof/pipe-dai-playback.m4,
	2, SSP, SSP_INDEX, SSP_NAME,
	PIPELINE_SOURCE_2, 2, s16le,
	1000, 0, 0, SCHEDULE_TIME_DOMAIN_TIMER)

# capture DAI is SSP(SSP_INDEX) using 2 periods
# Buffers use s16le format, 1000us deadline on core 0 with priority 0
DAI_ADD(sof/pipe-dai-capture.m4,
	3, SSP, SSP_INDEX, SSP_NAME,
	PIPELINE_SINK_3, 2, s16le,
	1000, 0, 0, SCHEDULE_TIME_DOMAIN_TIMER)

# playback DAI is iDisp1 using 2 periods
# Buffers use s32le format, 1000us deadline on core 0 with priority 0
DAI_ADD(sof/pipe-dai-playback.m4,
        5, HDA, HDMI0_INDEX, iDisp1,
        PIPELINE_SOURCE_5, 2, s32le,
        1000, 0, 0, SCHEDULE_TIME_DOMAIN_TIMER)

# playback DAI is iDisp2 using 2 periods
# Buffers use s32le format, 1000us deadline on core 0 with priority 0
DAI_ADD(sof/pipe-dai-playback.m4,
        6, HDA, HDMI1_INDEX, iDisp2,
        PIPELINE_SOURCE_6, 2, s32le,
        1000, 0, 0, SCHEDULE_TIME_DOMAIN_TIMER)

# playback DAI is iDisp3 using 2 periods
# Buffers use s32le format, 1000us deadline on core 0 with priority 0
DAI_ADD(sof/pipe-dai-playback.m4,
        7, HDA, HDMI2_INDEX, iDisp3,
        PIPELINE_SOURCE_7, 2, s32le,
        1000, 0, 0, SCHEDULE_TIME_DOMAIN_TIMER)

#
# DMIC and KWD configuration
#
define(DMIC_PIPELINE_48k_ID, 4)
define(DMIC_PCM_48k_ID, DMIC_PCM_NUM)
define(CHANNELS, 4)
define(KFBM_TYPE, kfbm)
define(DMIC_PIPELINE_16k_ID, 8)
define(DMIC_PCM_16k_ID, 8)
define(DMIC_PIPELINE_KWD_ID, 9)
define(DMIC_DAI_LINK_48k_ID, 2)
define(DMIC_DAI_LINK_16k_ID, 6)
define(DETECTOR_TYPE, google-hotword-detect)
include(`platform/intel/intel-generic-dmic-kwd.m4')

PCM_PLAYBACK_ADD(Speakers, 0, PIPELINE_PCM_1)
PCM_DUPLEX_ADD(Headset, 1, PIPELINE_PCM_2, PIPELINE_PCM_3)
PCM_PLAYBACK_ADD(HDMI1, 5, PIPELINE_PCM_5)
PCM_PLAYBACK_ADD(HDMI2, 6, PIPELINE_PCM_6)
PCM_PLAYBACK_ADD(HDMI3, 7, PIPELINE_PCM_7)

#
# BE configurations - overrides config in ACPI if present
#

DAI_CONFIG(SSP, 1, 0, SSP1-Codec,
        SSP_CONFIG(I2S, SSP_CLOCK(mclk, SSP_MCLK_RATE, codec_mclk_in),
                SSP_CLOCK(bclk, SSP1_BCLK, codec_slave),
                SSP_CLOCK(fsync, SSP_FSYNC, codec_slave),
                SSP_TDM(2, SSP1_VALID_BITS, 3, 3),
                SSP_CONFIG_DATA(SSP, 1, SSP1_VALID_BITS, MCLK_ID)))

DAI_CONFIG(SSP, SSP_INDEX, 1, SSP_NAME,
        SSP_CONFIG(I2S, SSP_CLOCK(mclk, SSP_MCLK_RATE, codec_mclk_in),
                SSP_CLOCK(bclk, SSP_BCLK, codec_slave),
                SSP_CLOCK(fsync, SSP_FSYNC, codec_slave),
                SSP_TDM(2, SSP_BITS_WIDTH, 3, 3),
                SSP_CONFIG_DATA(SSP, SSP_INDEX, SSP_VALID_BITS, MCLK_ID)))

# 3 HDMI/DP outputs (ID: 3,4,5)
DAI_CONFIG(HDA, HDMI0_INDEX, 3, iDisp1,
	HDA_CONFIG(HDA_CONFIG_DATA(HDA, HDMI0_INDEX, 48000, 2)))
DAI_CONFIG(HDA, HDMI1_INDEX, 4, iDisp2,
	HDA_CONFIG(HDA_CONFIG_DATA(HDA, HDMI1_INDEX, 48000, 2)))
DAI_CONFIG(HDA, HDMI2_INDEX, 5, iDisp3,
	HDA_CONFIG(HDA_CONFIG_DATA(HDA, HDMI2_INDEX, 48000, 2)))

## remove warnings with SST hard-coded routes

VIRTUAL_WIDGET(UNUSED_SSP_ROUTE1 Tx, out_drv, 0)
VIRTUAL_WIDGET(UNUSED_SSP_ROUTE2 Rx, out_drv, 1)
VIRTUAL_WIDGET(UNUSED_SSP_ROUTE2 Tx, out_drv, 2)
VIRTUAL_WIDGET(iDisp3 Tx, out_drv, 15)
VIRTUAL_WIDGET(iDisp2 Tx, out_drv, 16)
VIRTUAL_WIDGET(iDisp1 Tx, out_drv, 17)
VIRTUAL_WIDGET(DMIC01 Rx, out_drv, 3)
VIRTUAL_WIDGET(DMic, out_drv, 4)
VIRTUAL_WIDGET(dmic01_hifi, out_drv, 5)
VIRTUAL_WIDGET(hif5-0 Output, out_drv, 6)
VIRTUAL_WIDGET(hif6-0 Output, out_drv, 7)
VIRTUAL_WIDGET(hif7-0 Output, out_drv, 8)
VIRTUAL_WIDGET(iDisp3_out, out_drv, 9)
VIRTUAL_WIDGET(iDisp2_out, out_drv, 10)
VIRTUAL_WIDGET(iDisp1_out, out_drv, 11)
VIRTUAL_WIDGET(codec0_out, output, 12)
VIRTUAL_WIDGET(codec1_out, output, 13)
VIRTUAL_WIDGET(codec0_in, input, 14)

DEBUG_END
