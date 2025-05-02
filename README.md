# Focusfish

A delightful productivity app that combines focus timer functionality with virtual pet raising and fish collection mechanics.

## Overview

Focusfish is an iOS app designed to help you stay focused and productive using a gamified approach. It implements a focus timer (pomodoro technique) where each completed session rewards you with fish that you can collect or feed to your virtual pet. The more you focus, the more your collection grows and your pet evolves!

## Features

- **Focus Timer**: Two timer modes to suit your workflow:
  - **Countdown Mode**: Traditional pomodoro timer with set focus periods
  - **Count Up Mode**: Open-ended focus sessions (requires at least 25 minutes to earn rewards)
  
- **Virtual Pet**: Raise and nurture your cat or dog companion:
  - Feed them fish to increase their experience and level up
  - Switch between cat and dog at any time
  - Each pet has independent progress and stats

- **Fish Collection**: Collect various types of fish based on your focus time:
  - Common, Rare, and Epic fish varieties
  - Longer focus sessions increase chances of rarer fish
  - Each fish type has unique artwork and value

- **Habit Tracking**: Monitor your productivity with a heat map visualization:
  - Track daily focus sessions
  - View patterns over time
  - Associate sessions with specific habits

- **Customizable Settings**:
  - Adjust focus and break durations
  - Choose from different background sounds
  - Control sound volume and preferences

## Getting Started

### Prerequisites

- iOS 17.0+
- Xcode 15+
- macOS Ventura 13.5+

## How to Use

1. **Focus Timer**:
   - Select your preferred timer mode (Countdown or Count Up)
   - For Countdown mode, set your focus time duration
   - Press Start to begin your focus session
   - After completion, you'll be rewarded with a fish and a break timer will begin

2. **Pet Care**:
   - Navigate to the Pet tab to view your pet
   - Feed fish to your pet to gain experience points
   - Switch between cat and dog using the arrow button
   - Watch your pet level up as you feed it more fish

3. **Fish Collection**:
   - View your collected fish in the collection tab
   - Feed fish to your pet or keep them in your collection
   - Track which types of fish you've discovered

4. **Habit Tracking**:
   - Create habits to associate with your focus sessions
   - View your progress over time with the heat map
   - Monitor which habits you're maintaining consistently

## Technologies Used

- SwiftUI for the user interface
- Combine for reactive programming
- UserDefaults for data persistence
- AVFoundation for sound management

## Development

This app was developed as a project to demonstrate iOS development skills, particularly focusing on:

1. SwiftUI implementation
2. State management
3. Data modeling and persistence
4. UI/UX design principles
5. Gamification of productivity
