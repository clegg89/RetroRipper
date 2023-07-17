set(STM32_F0_COMPILE_OPTIONS
    $<$<C_COMPILER_ID:GNU>:-mcpu=cortex-m0>
)

set(STM32_F0_LINK_OPTIONS
    $<$<C_COMPILER_ID:GNU>:-mcpu=cortex-m0>
)
