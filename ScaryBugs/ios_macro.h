//
//  ios_macro.h
//  Created by Yue Xing on 10/14/15.
//
//

#ifndef ios_macro_h
#define ios_macro_h

#define HelNeueFontOfSize(s)  [UIFont fontWithName:@"HelveticaNeue" size: (s)]

#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed: ((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:        ((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:         ((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#endif /* ios_macro_h */
