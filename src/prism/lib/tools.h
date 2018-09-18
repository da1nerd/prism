#ifndef LIB_TOOL_LIBRARY_H
#define LIB_TOOL_LIBRARY_H

/**
 * Returns the image data of a PNG
 * @param  filename       the path to the image file
 * @param  width          the width of the image
 * @param  height         the height of the image
 * @param  color_channels the number of color channels
 * @return                the image data as bytes
 */
unsigned char *load_png(char const *filename, int *width, int *height, int *color_channels);

#endif
