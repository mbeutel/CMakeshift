#ifdef __cplusplus
extern "C" 
#endif /* __cplusplus */
__attribute__((no_sanitize_address))
__attribute__((weak)) /* prevent any linking errors when linking multiple CUDA libraries, and permit the user to override it by providing his own `__asan_default_options()` implementation */
__attribute__((visibility("default")))
const char* __asan_default_options(void)
{
		/* This option is used to make AddressSanitizer compatible with NVIDIA's CUDA runtime libraries and/or with NVCC, cf.
		   https://devtalk.nvidia.com/default/topic/1037466/cuda-runtime-library-and-addresssanitizer-incompatibilty/ and
		   https://github.com/google/sanitizers/issues/629 . */
    return "protect_shadow_gap=0";
}
