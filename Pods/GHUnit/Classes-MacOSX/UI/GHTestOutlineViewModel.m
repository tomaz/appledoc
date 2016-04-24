//
//  GHTestOutlineViewModel.m
//  GHUnit
//
//  Created by Gabriel Handford on 7/17/09.
//  Copyright 2009. All rights reserved.
//

#import "GHTestOutlineViewModel.h"

@implementation GHTestOutlineViewModel

@synthesize delegate;

#pragma mark DataSource (NSOutlineView)

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
	if (!item) {
		return [self root];
	} else {
		return [[item children] objectAtIndex:index];
	}
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {	
	return (!item) ? YES : ([[item children] count] > 0);
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
	return (!item) ? (self ? 1 : 0) : [[item children] count];
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
	if (!item) return nil;
	
	if (tableColumn == nil) {
		return [item nameWithStatus];
	} else if ([[tableColumn identifier] isEqual:@"status"] && ![item hasChildren]) {
		return [item statusString];
	}
	return nil;
}

- (void)outlineView:(NSOutlineView *)outlineView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {	
	if (self.isEditing) {
		if ([[tableColumn identifier] isEqual:@"name"]) {
			[item setSelected:[object boolValue]];		
			[outlineView reloadData];
		}	
	}
}

- (void)outlineView:(NSOutlineView *)outlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item {
	
	GHTestNode *test = (GHTestNode *)item;
	
	if ([[tableColumn identifier] isEqual:@"name"]) {
		
		NSColor *textColor = [NSColor blackColor];
		if ([test isHidden] || [test isDisabled]) {
			textColor = [NSColor grayColor];
		}		
		
		if (self.isEditing) {
			[cell setState:[item isSelected] ? NSOnState : NSOffState];
			NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
																	textColor, NSForegroundColorAttributeName,
																	[cell font],  NSFontAttributeName,
																	nil];
			
			NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:[item name] attributes:attributes];
			[cell setAttributedTitle:attributedString];
		} else {			
			[cell setTitle:[item name]];	
			[cell setTextColor:textColor];
		}
	}
	
	if ([[tableColumn identifier] isEqual:@"status"]) {
		[cell setTextColor:[NSColor lightGrayColor]];	
		
		if ([test status] == GHTestStatusErrored) {
			[cell setTextColor:[NSColor redColor]];
		} else if ([test status] == GHTestStatusSucceeded) {
			[cell setTextColor:[NSColor greenColor]];
		} else if ([test status] == GHTestStatusRunning) {
			[cell setTextColor:[NSColor blackColor]];
		}
	}		
}

// We can return a different cell for each row, if we want
- (NSCell *)outlineView:(NSOutlineView *)outlineView dataCellForTableColumn:(NSTableColumn *)tableColumn item:(id)item {
	// If we return a cell for the 'nil' tableColumn, it will be used as a "full width" cell and span all the columns
//	if (tableColumn == nil && [item hasChildren]) {
//		// We want to use the cell for the name column, but we could construct a new cell if we wanted to, or return a different cell for each row.
//		return [[outlineView tableColumnWithIdentifier:@"name"] dataCell];
//	}
	
	if ([[tableColumn identifier] isEqual:@"name"] && self.isEditing) {		
		// TODO(gabe): Doesn't work if you try to re-use cells so making a new one; 
		// Need help with this; This might explode if you have a lot of tests
		NSButtonCell *cell = [[NSButtonCell alloc] init];
		[cell setControlSize:NSSmallControlSize];
		[cell setFont:[NSFont fontWithName:@"Lucida Grande" size:11]];
		[cell setButtonType:NSSwitchButton];		
		[cell setTitle:[item name]];
		[cell setEditable:YES];
		return cell;
	}	
	
	return [tableColumn dataCell];
}

#pragma mark Delegates (NSOutlineView)

- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
	[self.delegate testOutlineViewModelDidChangeSelection:self];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item {
	NSInteger clickedCol = [outlineView clickedColumn];
	NSInteger clickedRow = [outlineView clickedRow];
	if (clickedRow >= 0 && clickedCol >= 0) {
		NSCell *cell = [outlineView preparedCellAtColumn:clickedCol row:clickedRow];
		if ([cell isKindOfClass:[NSButtonCell class]] && [cell isEnabled]) {
			return NO;
		}            
	}
	
	return (![item hasChildren]);
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item {
	return ([item hasChildren]);
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldTrackCell:(NSCell *)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item {
	// We want to allow tracking for all the button cells, even if we don't allow selecting that particular row. 
	if ([cell isKindOfClass:[NSButtonCell class]]) {
		// We can also take a peek and make sure that the part of the cell clicked is an area that is normally tracked. Otherwise, clicking outside of the checkbox may make it check the checkbox
		NSRect cellFrame = [outlineView frameOfCellAtColumn:[[outlineView tableColumns] indexOfObject:tableColumn] row:[outlineView rowForItem:item]];
		NSUInteger hitTestResult = [cell hitTestForEvent:[NSApp currentEvent] inRect:cellFrame ofView:outlineView];
		if (hitTestResult && NSCellHitTrackableArea != 0) {
			return YES;
		} else {
			return NO;
		}
	} else {
		// Only allow tracking on selected rows. This is what NSTableView does by default.
		return [outlineView isRowSelected:[outlineView rowForItem:item]];
	}
}

@end
