//
//  DiscoveryCitiesListCell.m
//  tango
//

#import "DiscoveryCitiesListCell.h"
#import "ios_macro.h"

@implementation DiscoveryCitiesListCell

- (void) updateWithLocation:(Location *) newLocation
{
  self.location = newLocation;
  
  NSString *locationName = [self.location.name stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
  NSString *locationRegion = self.location.region;
  
  if (locationRegion == nil) {
    locationRegion = @"";
    // Region is not set -- try to get it from location name
    NSArray *locationArray = [self.location.name componentsSeparatedByString:@","];
    if (locationArray.count >= 2) {
      locationName = [locationArray[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
      locationRegion = [locationArray[1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
  }

  NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:locationName];
  NSMutableAttributedString *attributedDetailText = [[NSMutableAttributedString alloc] initWithString:locationRegion];

  [attributedText addAttribute:NSFontAttributeName value:HelNeueFontOfSize(15) range:NSMakeRange(0, attributedText.length)];
  [attributedText addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0x666563) range:NSMakeRange(0, attributedText.length)];

  [attributedDetailText addAttribute:NSFontAttributeName value:HelNeueFontOfSize(13) range:NSMakeRange(0, attributedDetailText.length)];
  [attributedDetailText addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0xB3B3B3) range:NSMakeRange(0, attributedDetailText.length)];

  self.textLabel.attributedText = attributedText;
  self.detailTextLabel.attributedText = attributedDetailText;
}

@end
