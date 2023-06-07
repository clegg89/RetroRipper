# Adapted from https://github.com/ObKo/stm32-cmake
# Provide a set of functions to generate imported libraries
# for a given STM32 part
#
# For a given part, i.e. the STM32F103RB we can break it down into:
#    * Family - What ST calls the "Series" (F1 in this example)
#    * Type - What ST calls the "Product Line" (F103 in this example).
#      we will typically append 'xx' here, so F103xx
#    * Device - The full microcontroller part (F103RB). This simply
#      adds the information on the pin count and memory to the Type.
#
# We define interface libraries for both the Family and the Type.
# No library is needed at this level for the Device, as that is the
# domain of the CMSIS and HAL.
#
# The Family library is mainly concerned with compiler and linker
# flags, as this determines what CPU is being targetted and whether
# or not an FPU is available.
#
# The Type library typically adds a preprocessor definition for the type,
# (i.e. STM32F103xx) but does sometimes add additional compiler/linker
# flags.