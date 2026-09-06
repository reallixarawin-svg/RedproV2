# Auto-Elevate to Administrator
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    $scriptPath = if ($PSCommandPath) { $PSCommandPath } else { $MyInvocation.MyCommand.Path }
    if ($scriptPath) {
        try { Start-Process powershell.exe -ArgumentList "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$scriptPath`"" -Verb RunAs } catch {}
    }
    Exit
}

# Force TLS 1.2 Security Protocol for HTTPS requests
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Hide PowerShell Console Window
$code = @"
using System;
using System.Runtime.InteropServices;
public class Win32 {
    [DllImport("kernel32.dll")]
    public static extern IntPtr GetConsoleWindow();
    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
}
"@
Add-Type -TypeDefinition $code
[Win32]::ShowWindow([Win32]::GetConsoleWindow(), 0) | Out-Null

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
if (-not $scriptDir) { $scriptDir = $PWD.Path }
$wpfGifPath = Join-Path $scriptDir "WpfAnimatedGif.dll"
if (Test-Path $wpfGifPath) {
    Add-Type -Path $wpfGifPath
}

Add-Type -AssemblyName PresentationFramework

$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" xmlns:gif="clr-namespace:WpfAnimatedGif;assembly=WpfAnimatedGif" Title="Redpro Setting V2" Height="820" Width="1200" WindowStyle="None" AllowsTransparency="True" Background="Transparent" WindowStartupLocation="CenterScreen" RenderOptions.BitmapScalingMode="HighQuality" TextOptions.TextFormattingMode="Display" FontFamily="Leelawadee UI, Segoe UI"><Window.Resources><SolidColorBrush x:Key="TitleDotColor" Color="#F2F4F8" /><SolidColorBrush x:Key="WindowControlForeground" Color="White" /><LinearGradientBrush x:Key="AccentGradient" StartPoint="0,0" EndPoint="1,1"><GradientStop Color="#F2F4F8" Offset="0.0" /><GradientStop Color="#AEB9CC" Offset="1.0" /></LinearGradientBrush><LinearGradientBrush x:Key="CardGradient" StartPoint="0,0" EndPoint="0,1"><GradientStop Color="#191E2B" Offset="0.0" /><GradientStop Color="#131722" Offset="1.0" /></LinearGradientBrush><Style TargetType="Button" x:Key="PremiumButton"><Setter Property="Background"><Setter.Value><LinearGradientBrush StartPoint="0,0" EndPoint="1,0"><GradientStop Color="#6D28D9" Offset="0" /><GradientStop Color="#B779FF" Offset="0.45" /><GradientStop Color="#7C3AED" Offset="1" /></LinearGradientBrush></Setter.Value></Setter><Setter Property="Foreground" Value="White" /><Setter Property="FontWeight" Value="SemiBold" /><Setter Property="FontSize" Value="14" /><Setter Property="Cursor" Value="Hand" /><Setter Property="Template"><Setter.Value><ControlTemplate TargetType="Button"><Border Background="{TemplateBinding Background}" CornerRadius="12" BorderThickness="0"><ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center" Margin="10,0" /></Border></ControlTemplate></Setter.Value></Setter><Style.Triggers><Trigger Property="IsMouseOver" Value="True"><Setter Property="Opacity" Value="0.9" /></Trigger><Trigger Property="IsPressed" Value="True"><Setter Property="Opacity" Value="0.7" /></Trigger><EventTrigger xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" RoutedEvent="FrameworkElement.Loaded"><BeginStoryboard><Storyboard RepeatBehavior="Forever" AutoReverse="True" Timeline.DesiredFrameRate="30"><DoubleAnimation Storyboard.TargetProperty="(Control.Background).(GradientBrush.GradientStops)[1].(GradientStop.Offset)" From="0.15" To="0.85" Duration="0:0:2.5" /></Storyboard></BeginStoryboard></EventTrigger></Style.Triggers></Style><Style TargetType="Button" x:Key="SecondaryButton"><Setter Property="Background" Value="#242C3C" /><Setter Property="Foreground" Value="#E2E8F2" /><Setter Property="FontWeight" Value="SemiBold" /><Setter Property="Cursor" Value="Hand" /><Setter Property="Template"><Setter.Value><ControlTemplate TargetType="Button"><Border Background="{TemplateBinding Background}" BorderBrush="#30394C" BorderThickness="1" CornerRadius="12"><ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center" Margin="10,0" /></Border></ControlTemplate></Setter.Value></Setter><Style.Triggers><Trigger Property="IsMouseOver" Value="True"><Setter Property="Background" Value="#30394C" /><Setter Property="BorderBrush" Value="#444444" /></Trigger><Trigger Property="IsPressed" Value="True"><Setter Property="Opacity" Value="0.7" /></Trigger></Style.Triggers></Style><Style TargetType="Button" x:Key="MenuButton"><Setter Property="Background" Value="Transparent" /><Setter Property="Foreground" Value="#A1AEC3" /><Setter Property="Height" Value="40" /><Setter Property="FontSize" Value="14" /><Setter Property="FontWeight" Value="Medium" /><Setter Property="Cursor" Value="Hand" /><Setter Property="FocusVisualStyle" Value="{x:Null}" /><Setter Property="Template"><Setter.Value><ControlTemplate TargetType="Button"><Border Background="{TemplateBinding Background}" CornerRadius="6" Margin="10,2"><ContentPresenter HorizontalAlignment="Left" VerticalAlignment="Center" Margin="20,0,0,0" /></Border></ControlTemplate></Setter.Value></Setter><Style.Triggers><Trigger Property="IsMouseOver" Value="True"><Setter Property="Background" Value="#243044" /><Setter Property="Foreground" Value="#F2F4F8" /></Trigger></Style.Triggers></Style><Style TargetType="Button" x:Key="ActiveMenuButton" BasedOn="{StaticResource MenuButton}"><Setter Property="Background" Value="#358B5CF6" /><Setter Property="Foreground" Value="#F2F4F8" /><Setter Property="Template"><Setter.Value><ControlTemplate TargetType="Button"><Border Background="{TemplateBinding Background}" CornerRadius="6" Margin="10,2"><Grid><Border Width="4" HorizontalAlignment="Left" Background="#F2F4F8" CornerRadius="6,0,0,6" /><ContentPresenter HorizontalAlignment="Left" VerticalAlignment="Center" Margin="15,0,0,0" /></Grid></Border></ControlTemplate></Setter.Value></Setter></Style><Style TargetType="Button" x:Key="WindowControlButton"><Setter Property="Background" Value="Transparent" /><Setter Property="Foreground" Value="{DynamicResource WindowControlForeground}" /><Setter Property="Cursor" Value="Hand" /><Setter Property="Template"><Setter.Value><ControlTemplate TargetType="Button"><Border Background="{TemplateBinding Background}" CornerRadius="6" Margin="4"><ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center" /></Border></ControlTemplate></Setter.Value></Setter><Style.Triggers><Trigger Property="IsMouseOver" Value="True"><Setter Property="Background" Value="#243044" /><Setter Property="Foreground" Value="#F2F4F8" /></Trigger></Style.Triggers></Style><Style TargetType="Button" x:Key="CloseButton" BasedOn="{StaticResource WindowControlButton}"><Style.Triggers><Trigger Property="IsMouseOver" Value="True"><Setter Property="Background" Value="#e81123" /><Setter Property="Foreground" Value="#F2F4F8" /></Trigger></Style.Triggers></Style><Style x:Key="PremiumSlider" TargetType="Slider"><Setter Property="Template"><Setter.Value><ControlTemplate TargetType="Slider"><Grid><Border x:Name="TrackBackground" Background="#222" Height="4" CornerRadius="2" VerticalAlignment="Center" Margin="5,0" /><Track x:Name="PART_Track"><Track.DecreaseRepeatButton><RepeatButton Command="{x:Static Slider.DecreaseLarge}"><RepeatButton.Template><ControlTemplate TargetType="RepeatButton"><Border Height="4" Background="#131722" CornerRadius="2" Margin="5,0,0,0" /></ControlTemplate></RepeatButton.Template></RepeatButton></Track.DecreaseRepeatButton><Track.IncreaseRepeatButton><RepeatButton Command="{x:Static Slider.IncreaseLarge}"><RepeatButton.Template><ControlTemplate TargetType="RepeatButton"><Border Height="4" Background="Transparent" /></ControlTemplate></RepeatButton.Template></RepeatButton></Track.IncreaseRepeatButton><Track.Thumb><Thumb x:Name="Thumb"><Thumb.Template><ControlTemplate TargetType="Thumb"><Ellipse Width="12" Height="12" Fill="#131722" Stroke="White" StrokeThickness="1.5" Cursor="Hand"><Ellipse.Effect><DropShadowEffect BlurRadius="5" ShadowDepth="0" Color="#000000" Opacity="0.1" /></Ellipse.Effect></Ellipse></ControlTemplate></Thumb.Template></Thumb></Track.Thumb></Track></Grid></ControlTemplate></Setter.Value></Setter></Style></Window.Resources><Border CornerRadius="12" BorderThickness="1" BorderBrush="#2C3445"><Border.Background><LinearGradientBrush StartPoint="0,0" EndPoint="1,1"><GradientStop Color="#0E1119" Offset="0" /><GradientStop Color="#131722" Offset="1" /></LinearGradientBrush></Border.Background><Grid><Grid.RowDefinitions><RowDefinition Height="40" /><RowDefinition Height="*" /></Grid.RowDefinitions><Image x:Name="BgMedia" Grid.RowSpan="2" Stretch="UniformToFill" Opacity="0.07" HorizontalAlignment="Stretch" VerticalAlignment="Stretch" gif:ImageBehavior.AnimatedSource="BG_PATH_PLACEHOLDER" /><Grid xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" x:Name="AmbientBackground" Grid.RowSpan="2" IsHitTestVisible="False" ClipToBounds="True"><Ellipse Width="850" Height="680" HorizontalAlignment="Right" VerticalAlignment="Top" Margin="0,-160,-150,0" Opacity="0.65"><Ellipse.Fill><RadialGradientBrush><GradientStop Color="#CC8B3DFF" Offset="0" /><GradientStop Color="#003B206A" Offset="1" /></RadialGradientBrush></Ellipse.Fill><Ellipse.RenderTransform><TranslateTransform /></Ellipse.RenderTransform><Ellipse.Triggers><EventTrigger RoutedEvent="FrameworkElement.Loaded"><BeginStoryboard><Storyboard RepeatBehavior="Forever" AutoReverse="True" Timeline.DesiredFrameRate="30"><DoubleAnimation Storyboard.TargetProperty="(UIElement.RenderTransform).(TranslateTransform.X)" From="-250" To="250" Duration="0:0:5"><DoubleAnimation.EasingFunction><SineEase EasingMode="EaseInOut" /></DoubleAnimation.EasingFunction></DoubleAnimation><DoubleAnimation Storyboard.TargetProperty="(UIElement.RenderTransform).(TranslateTransform.Y)" From="0" To="140" Duration="0:0:5" /><DoubleAnimation Storyboard.TargetProperty="Opacity" From="0.7" To="1" Duration="0:0:5" /></Storyboard></BeginStoryboard></EventTrigger></Ellipse.Triggers></Ellipse><Ellipse Width="750" Height="600" HorizontalAlignment="Left" VerticalAlignment="Bottom" Margin="80,0,0,-220" Opacity="0.55"><Ellipse.Fill><RadialGradientBrush><GradientStop Color="#CC8B3DFF" Offset="0" /><GradientStop Color="#00251A50" Offset="1" /></RadialGradientBrush></Ellipse.Fill><Ellipse.RenderTransform><TranslateTransform /></Ellipse.RenderTransform><Ellipse.Triggers><EventTrigger RoutedEvent="FrameworkElement.Loaded"><BeginStoryboard><Storyboard RepeatBehavior="Forever" AutoReverse="True" Timeline.DesiredFrameRate="30"><DoubleAnimation Storyboard.TargetProperty="(UIElement.RenderTransform).(TranslateTransform.X)" From="-250" To="250" Duration="0:0:5"><DoubleAnimation.EasingFunction><SineEase EasingMode="EaseInOut" /></DoubleAnimation.EasingFunction></DoubleAnimation><DoubleAnimation Storyboard.TargetProperty="(UIElement.RenderTransform).(TranslateTransform.Y)" From="50" To="-100" Duration="0:0:5" /></Storyboard></BeginStoryboard></EventTrigger></Ellipse.Triggers></Ellipse></Grid><Grid Grid.Row="0" Background="Transparent" x:Name="TitleBar"><StackPanel Orientation="Horizontal" VerticalAlignment="Center" Margin="20,0,0,0"><Ellipse x:Name="TitleDot" Width="6" Height="6" Fill="White" /><TextBlock Text="Redpro Setting V2" Foreground="#F2F4F8" FontWeight="Bold" Margin="8,0,0,0" FontSize="11" FontFamily="Segoe UI" /></StackPanel><StackPanel Orientation="Horizontal" HorizontalAlignment="Right" VerticalAlignment="Stretch"><Slider x:Name="VolumeSlider" Style="{StaticResource PremiumSlider}" Visibility="Collapsed" Width="80" Minimum="0" Maximum="1" Value="0.3" VerticalAlignment="Center" Margin="0,0,5,0" /><Button Content="" FontFamily="Segoe MDL2 Assets" Width="40" Style="{StaticResource WindowControlButton}" FontSize="14" x:Name="BtnMuteToggle" ToolTip="Mute/Unmute" /><Button Content="" FontFamily="Segoe MDL2 Assets" Width="50" Style="{StaticResource WindowControlButton}" FontSize="10" x:Name="BtnMinimize" /><Button Content="" FontFamily="Segoe MDL2 Assets" Width="50" Style="{StaticResource CloseButton}" FontSize="10" x:Name="BtnClose" /></StackPanel></Grid><Grid x:Name="MainAppContainer" Grid.Row="1" Visibility="Collapsed"><Grid.ColumnDefinitions><ColumnDefinition Width="260" /><ColumnDefinition Width="*" /></Grid.ColumnDefinitions><Border Grid.Column="0" Background="#F211151F" BorderThickness="0,0,1,0" BorderBrush="#293143" CornerRadius="0" ClipToBounds="True"><Grid><Grid.RowDefinitions><RowDefinition Height="Auto" /><RowDefinition Height="*" /><RowDefinition Height="Auto" /></Grid.RowDefinitions><StackPanel Grid.Row="0"><Grid Width="86" Height="86" Margin="0,20,0,5" HorizontalAlignment="Center" RenderTransformOrigin="0.5,0.5"><Grid.RenderTransform><ScaleTransform ScaleX="1" ScaleY="1" /></Grid.RenderTransform><Grid.Triggers><EventTrigger RoutedEvent="FrameworkElement.Loaded"><BeginStoryboard><Storyboard RepeatBehavior="Forever" AutoReverse="True"><DoubleAnimation Storyboard.TargetProperty="(UIElement.RenderTransform).(ScaleTransform.ScaleX)" From="1.0" To="1.06" Duration="0:0:2.0"><DoubleAnimation.EasingFunction><SineEase EasingMode="EaseInOut" /></DoubleAnimation.EasingFunction></DoubleAnimation><DoubleAnimation Storyboard.TargetProperty="(UIElement.RenderTransform).(ScaleTransform.ScaleY)" From="1.0" To="1.06" Duration="0:0:2.0"><DoubleAnimation.EasingFunction><SineEase EasingMode="EaseInOut" /></DoubleAnimation.EasingFunction></DoubleAnimation></Storyboard></BeginStoryboard></EventTrigger></Grid.Triggers><!-- Rotating Container --><Grid Width="86" Height="86" RenderTransformOrigin="0.5,0.5"><Grid.RenderTransform><RotateTransform Angle="0" /></Grid.RenderTransform><Grid.Triggers><EventTrigger RoutedEvent="FrameworkElement.Loaded"><BeginStoryboard><Storyboard><DoubleAnimation Storyboard.TargetProperty="(UIElement.RenderTransform).(RotateTransform.Angle)" From="0" To="360" Duration="0:0:1.6"><DoubleAnimation.EasingFunction><QuarticEase EasingMode="EaseOut" /></DoubleAnimation.EasingFunction></DoubleAnimation></Storyboard></BeginStoryboard></EventTrigger></Grid.Triggers><!-- White Frame Background Circle --><Ellipse Width="86" Height="86" Fill="White"><Ellipse.Stroke><SolidColorBrush Color="#000000" Opacity="0.1" /></Ellipse.Stroke><Ellipse.StrokeThickness>1</Ellipse.StrokeThickness><Ellipse.Effect><DropShadowEffect Color="#000000" BlurRadius="10" ShadowDepth="2" Opacity="0.12" /></Ellipse.Effect></Ellipse><!-- Profile Image Overlay --><Ellipse x:Name="ProfileImage" Width="80" Height="80" Fill="#151515" RenderOptions.BitmapScalingMode="HighQuality" VerticalAlignment="Center" HorizontalAlignment="Center" /></Grid></Grid><TextBlock Text="Redpro Setting V2" Foreground="#F2F4F8" FontWeight="Bold" FontSize="16" HorizontalAlignment="Center" Margin="0,2,0,0" /><TextBlock Text="PREMIUM OPTIMIZER" Foreground="#F2F4F8" FontSize="10" FontWeight="Bold" HorizontalAlignment="Center" Margin="0,2,0,15" /></StackPanel><ScrollViewer Grid.Row="1" VerticalScrollBarVisibility="Hidden"><StackPanel Margin="0,0,0,0"><Button x:Name="BtnNavDashboard" Style="{StaticResource ActiveMenuButton}"><StackPanel Orientation="Horizontal"><TextBlock FontFamily="Segoe MDL2 Assets" Text="" FontSize="16" Width="30" VerticalAlignment="Center" Margin="0,-2,0,0" /><TextBlock Text="Dashboard" VerticalAlignment="Center" /></StackPanel></Button><Button x:Name="BtnNavCPU" Style="{StaticResource MenuButton}"><StackPanel Orientation="Horizontal"><TextBlock FontFamily="Segoe MDL2 Assets" Text="" FontSize="16" Width="30" VerticalAlignment="Center" Margin="0,-2,0,0" /><TextBlock Text="CPU / Priority" VerticalAlignment="Center" /></StackPanel></Button><Button x:Name="BtnNavInput" Style="{StaticResource MenuButton}"><StackPanel Orientation="Horizontal"><TextBlock FontFamily="Segoe MDL2 Assets" Text="" FontSize="16" Width="30" VerticalAlignment="Center" Margin="0,-2,0,0" /><TextBlock Text="Input" VerticalAlignment="Center" /></StackPanel></Button><Button x:Name="BtnNavNetwork" Style="{StaticResource MenuButton}"><StackPanel Orientation="Horizontal"><TextBlock FontFamily="Segoe MDL2 Assets" Text="" FontSize="16" Width="30" VerticalAlignment="Center" Margin="0,-2,0,0" /><TextBlock Text="Network" VerticalAlignment="Center" /></StackPanel></Button><Button x:Name="BtnNavFiveM" Style="{StaticResource MenuButton}"><StackPanel Orientation="Horizontal"><TextBlock FontFamily="Segoe MDL2 Assets" Text="" FontSize="16" Width="30" VerticalAlignment="Center" Margin="0,-2,0,0" /><TextBlock Text="FiveM / MTU" VerticalAlignment="Center" /></StackPanel></Button><Button x:Name="BtnNavPower" Style="{StaticResource MenuButton}"><StackPanel Orientation="Horizontal"><TextBlock FontFamily="Segoe MDL2 Assets" Text="" FontSize="16" Width="30" VerticalAlignment="Center" Margin="0,-2,0,0" /><TextBlock Text="Power / Timer" VerticalAlignment="Center" /></StackPanel></Button><Button x:Name="BtnNavTools" Style="{StaticResource MenuButton}"><StackPanel Orientation="Horizontal"><TextBlock FontFamily="Segoe MDL2 Assets" Text="" FontSize="16" Width="30" VerticalAlignment="Center" Margin="0,-2,0,0" /><TextBlock Text="Tools" VerticalAlignment="Center" /></StackPanel></Button><Button x:Name="BtnNavRestore" Style="{StaticResource MenuButton}"><StackPanel Orientation="Horizontal"><TextBlock FontFamily="Segoe MDL2 Assets" Text="" FontSize="16" Width="30" VerticalAlignment="Center" Margin="0,-2,0,0" /><TextBlock Text="Restore" VerticalAlignment="Center" /></StackPanel></Button></StackPanel></ScrollViewer><!-- Premium Sidebar Image with Outer Glow and Overlays --><Grid Grid.Row="2" Margin="20,10,20,25" RenderTransformOrigin="0.5,0.5"><Grid.RenderTransform><ScaleTransform ScaleX="1.0" ScaleY="1.0" /></Grid.RenderTransform><Grid.Triggers><EventTrigger RoutedEvent="Grid.Loaded"><BeginStoryboard><Storyboard><DoubleAnimation Storyboard.TargetProperty="(UIElement.RenderTransform).(ScaleTransform.ScaleX)" From="1.0" To="1.03" Duration="0:0:4" AutoReverse="True" RepeatBehavior="Forever" /><DoubleAnimation Storyboard.TargetProperty="(UIElement.RenderTransform).(ScaleTransform.ScaleY)" From="1.0" To="1.03" Duration="0:0:4" AutoReverse="True" RepeatBehavior="Forever" /></Storyboard></BeginStoryboard></EventTrigger></Grid.Triggers><!-- Subtle Purple Outer Glow (Animated Pulsing) --><Border Background="#222222" CornerRadius="12" Margin="10" Opacity="0.4"><Border.Effect><BlurEffect Radius="30" /></Border.Effect><Border.Triggers><EventTrigger RoutedEvent="Border.Loaded"><BeginStoryboard><Storyboard><DoubleAnimation Storyboard.TargetProperty="Opacity" From="0.3" To="0.85" Duration="0:0:2.5" AutoReverse="True" RepeatBehavior="Forever" /></Storyboard></BeginStoryboard></EventTrigger></Border.Triggers></Border><!-- Main Image Border --><Border Height="240" Background="#0f0f0f" CornerRadius="12" BorderThickness="1" BorderBrush="#30394C" ClipToBounds="True"><Grid><!-- Animated Background Image Layer --><Grid x:Name="SidebarImage" RenderTransformOrigin="0.5,0.5"><Grid.RenderTransform><ScaleTransform ScaleX="1.0" ScaleY="1.0" /></Grid.RenderTransform><Grid.Triggers><EventTrigger RoutedEvent="Grid.Loaded"><BeginStoryboard><Storyboard RepeatBehavior="Forever" AutoReverse="True"><DoubleAnimation Storyboard.TargetProperty="(UIElement.RenderTransform).(ScaleTransform.ScaleX)" From="1.0" To="1.12" Duration="0:0:10"><DoubleAnimation.EasingFunction><SineEase EasingMode="EaseInOut" /></DoubleAnimation.EasingFunction></DoubleAnimation><DoubleAnimation Storyboard.TargetProperty="(UIElement.RenderTransform).(ScaleTransform.ScaleY)" From="1.0" To="1.12" Duration="0:0:10"><DoubleAnimation.EasingFunction><SineEase EasingMode="EaseInOut" /></DoubleAnimation.EasingFunction></DoubleAnimation></Storyboard></BeginStoryboard></EventTrigger></Grid.Triggers></Grid><TextBlock x:Name="SidebarPlaceholderText" Text="[Image Placeholder]" Foreground="#A1AEC3" HorizontalAlignment="Center" VerticalAlignment="Center" /><!-- Dark Premium Gradient Overlay --><Border><Border.Background><LinearGradientBrush StartPoint="0,1" EndPoint="0,0"><GradientStop Color="#050505" Offset="0.0" /><GradientStop Color="#CC050505" Offset="0.3" /><GradientStop Color="#00050505" Offset="0.7" /></LinearGradientBrush></Border.Background></Border><!-- Premium Animated Smoke Effect --><Canvas Opacity="0.5"><!-- Smoke Puff 1 --><Ellipse Width="300" Height="200" Canvas.Left="-50" Canvas.Top="100"><Ellipse.Fill><RadialGradientBrush><GradientStop Color="#44ffffff" Offset="0" /><GradientStop Color="#303D2264" Offset="1" /></RadialGradientBrush></Ellipse.Fill><Ellipse.Effect><BlurEffect Radius="60" /></Ellipse.Effect><Ellipse.Triggers><EventTrigger RoutedEvent="Ellipse.Loaded"><BeginStoryboard><Storyboard RepeatBehavior="Forever" AutoReverse="True"><DoubleAnimation Storyboard.TargetProperty="(Canvas.Left)" From="-100" To="100" Duration="0:0:15"><DoubleAnimation.EasingFunction><SineEase EasingMode="EaseInOut" /></DoubleAnimation.EasingFunction></DoubleAnimation><DoubleAnimation Storyboard.TargetProperty="Opacity" From="0.3" To="0.8" Duration="0:0:8" AutoReverse="True"><DoubleAnimation.EasingFunction><SineEase EasingMode="EaseInOut" /></DoubleAnimation.EasingFunction></DoubleAnimation></Storyboard></BeginStoryboard></EventTrigger></Ellipse.Triggers></Ellipse><!-- Smoke Puff 2 --><Ellipse Width="400" Height="250" Canvas.Left="300" Canvas.Top="50"><Ellipse.Fill><RadialGradientBrush><GradientStop Color="#33aaaaaa" Offset="0" /><GradientStop Color="#00aaaaaa" Offset="1" /></RadialGradientBrush></Ellipse.Fill><Ellipse.Effect><BlurEffect Radius="80" /></Ellipse.Effect><Ellipse.Triggers><EventTrigger RoutedEvent="Ellipse.Loaded"><BeginStoryboard><Storyboard RepeatBehavior="Forever" AutoReverse="True"><DoubleAnimation Storyboard.TargetProperty="(Canvas.Left)" From="400" To="200" Duration="0:0:20"><DoubleAnimation.EasingFunction><SineEase EasingMode="EaseInOut" /></DoubleAnimation.EasingFunction></DoubleAnimation><DoubleAnimation Storyboard.TargetProperty="Opacity" From="0.2" To="0.6" Duration="0:0:12" AutoReverse="True"><DoubleAnimation.EasingFunction><SineEase EasingMode="EaseInOut" /></DoubleAnimation.EasingFunction></DoubleAnimation></Storyboard></BeginStoryboard></EventTrigger></Ellipse.Triggers></Ellipse><!-- Smoke Puff 3 --><Ellipse Width="350" Height="200" Canvas.Left="500" Canvas.Top="150"><Ellipse.Fill><RadialGradientBrush><GradientStop Color="#55cccccc" Offset="0" /><GradientStop Color="#00cccccc" Offset="1" /></RadialGradientBrush></Ellipse.Fill><Ellipse.Effect><BlurEffect Radius="70" /></Ellipse.Effect><Ellipse.Triggers><EventTrigger RoutedEvent="Ellipse.Loaded"><BeginStoryboard><Storyboard RepeatBehavior="Forever" AutoReverse="True"><DoubleAnimation Storyboard.TargetProperty="(Canvas.Left)" From="600" To="400" Duration="0:0:18"><DoubleAnimation.EasingFunction><SineEase EasingMode="EaseInOut" /></DoubleAnimation.EasingFunction></DoubleAnimation><DoubleAnimation Storyboard.TargetProperty="(Canvas.Top)" From="150" To="100" Duration="0:0:22"><DoubleAnimation.EasingFunction><SineEase EasingMode="EaseInOut" /></DoubleAnimation.EasingFunction></DoubleAnimation></Storyboard></BeginStoryboard></EventTrigger></Ellipse.Triggers></Ellipse></Canvas><!-- Tech Grid and Elements --><Canvas><!-- Top Left Bracket --><Path Data="M 2 20 L 2 2 L 20 2" Stroke="#131722" StrokeThickness="3" Opacity="0.9" Canvas.Top="20" Canvas.Left="20" /><!-- Faint grid lines (vertical and horizontal) --><Line X1="0" Y1="120" X2="1000" Y2="120" Stroke="#11ffffff" StrokeThickness="1" /><Line X1="400" Y1="0" X2="400" Y2="240" Stroke="#11ffffff" StrokeThickness="1" /><Line X1="600" Y1="0" X2="600" Y2="240" Stroke="#11ffffff" StrokeThickness="1" /></Canvas><!-- Heavy Text Section --><Border HorizontalAlignment="Left" VerticalAlignment="Bottom" Margin="30,0,0,25"><StackPanel><TextBlock Text="REDPRO" Foreground="White" FontFamily="Impact" FontSize="32" Opacity="0.95"><TextBlock.Effect><DropShadowEffect BlurRadius="8" ShadowDepth="4" Direction="270" Color="Black" Opacity="0.9" /></TextBlock.Effect></TextBlock><TextBlock Text="Setting Remake By.redpro" Foreground="White" FontFamily="Segoe UI" FontSize="11" FontWeight="Bold" Margin="2,0,0,0" Opacity="0.9"><TextBlock.Effect><DropShadowEffect BlurRadius="6" ShadowDepth="2" Direction="270" Color="Black" Opacity="0.9" /></TextBlock.Effect></TextBlock></StackPanel></Border></Grid></Border></Grid></Grid></Border><!-- VIEWS CONTAINER --><Grid Grid.Column="1" Margin="32,26,32,26"><Grid.RowDefinitions><RowDefinition Height="*" /><RowDefinition Height="Auto" /></Grid.RowDefinitions><Grid Grid.Row="0"><!-- VIEW 1: DASHBOARD --><Grid x:Name="ViewDashboard" Visibility="Visible"><Grid.RowDefinitions><RowDefinition Height="Auto" /><RowDefinition Height="Auto" /><RowDefinition Height="*" /></Grid.RowDefinitions><StackPanel Grid.Row="0" Margin="0,0,0,20"><TextBlock Text="Dashboard" Foreground="#F2F4F8" FontSize="30" FontWeight="Bold" /><TextBlock Text="แดชบอร์ดแสดงสถานะและปรับแต่งระบบ" Foreground="#F2F4F8" FontSize="15" Margin="0,6,0,0" /></StackPanel><Border x:Name="BannerImage" Grid.Row="1" Height="140" CornerRadius="16" Margin="0,0,0,25" BorderThickness="1" BorderBrush="#2C3445" ClipToBounds="True"><Border.Background><SolidColorBrush Color="#131722" /></Border.Background><Grid><Rectangle HorizontalAlignment="Stretch" VerticalAlignment="Stretch"><Rectangle.Fill><LinearGradientBrush StartPoint="0,0" EndPoint="1,0"><GradientStop Color="#F2181D2B" Offset="0.0" /><GradientStop Color="#D0201935" Offset="0.4" /><GradientStop Color="#303D2264" Offset="0.8" /></LinearGradientBrush></Rectangle.Fill></Rectangle><Grid xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" x:Name="PurpleFlow" IsHitTestVisible="False" ClipToBounds="True"><Grid.Background><LinearGradientBrush StartPoint="0,0" EndPoint="1,1"><GradientStop Color="#F220123F" Offset="0" /><GradientStop Color="#D04C2281" Offset="1" /></LinearGradientBrush></Grid.Background><Ellipse Width="580" Height="330" HorizontalAlignment="Left" VerticalAlignment="Center" Opacity="0.9"><Ellipse.Fill><RadialGradientBrush><GradientStop Color="#DDAC65FF" Offset="0" /><GradientStop Color="#005A1BB0" Offset="1" /></RadialGradientBrush></Ellipse.Fill><Ellipse.RenderTransform><TranslateTransform /></Ellipse.RenderTransform><Ellipse.Triggers><EventTrigger RoutedEvent="FrameworkElement.Loaded"><BeginStoryboard><Storyboard RepeatBehavior="Forever" AutoReverse="True" Timeline.DesiredFrameRate="30"><DoubleAnimation Storyboard.TargetProperty="(UIElement.RenderTransform).(TranslateTransform.X)" From="-250" To="650" Duration="0:0:5"><DoubleAnimation.EasingFunction><SineEase EasingMode="EaseInOut" /></DoubleAnimation.EasingFunction></DoubleAnimation></Storyboard></BeginStoryboard></EventTrigger></Ellipse.Triggers></Ellipse></Grid><Rectangle Height="1" VerticalAlignment="Bottom" HorizontalAlignment="Stretch" Fill="#30394C" /><StackPanel VerticalAlignment="Center" Margin="30,0,0,0" HorizontalAlignment="Left"><TextBlock Text="Your setup. Elevated." Foreground="#F2F4F8" FontSize="30" FontWeight="SemiBold"><TextBlock.Effect><DropShadowEffect BlurRadius="10" ShadowDepth="2" Direction="270" Opacity="0.5" Color="Black" /></TextBlock.Effect></TextBlock><TextBlock Text="PERFORMANCE STUDIO  /  REDPRO V2" Foreground="#F2F4F8" FontSize="10" Margin="2,4,0,0" FontWeight="Bold"><TextBlock.Effect><DropShadowEffect BlurRadius="5" ShadowDepth="1" Direction="270" Opacity="0.8" Color="Black" /></TextBlock.Effect></TextBlock></StackPanel></Grid></Border><Grid Grid.Row="2"><Grid.RowDefinitions><RowDefinition Height="Auto" /><RowDefinition Height="Auto" /></Grid.RowDefinitions><Grid.ColumnDefinitions><ColumnDefinition Width="*" /><ColumnDefinition Width="*" /></Grid.ColumnDefinitions><!-- SYSTEM --><Border Grid.Row="0" Grid.Column="0" Background="{StaticResource CardGradient}" CornerRadius="12" Margin="0,0,15,15" Padding="25" BorderThickness="1" BorderBrush="#2C3445"><Border.Effect><DropShadowEffect BlurRadius="15" ShadowDepth="4" Opacity="0.1" Direction="270" Color="Black" /></Border.Effect><StackPanel><StackPanel Orientation="Horizontal" Margin="0,0,0,20"><Rectangle Width="4" Height="18" Fill="{StaticResource AccentGradient}" Margin="0,0,12,0" RadiusX="2" RadiusY="2" /><TextBlock Text="SYSTEM" Foreground="#F2F4F8" FontWeight="Bold" FontSize="16" /></StackPanel><TextBlock x:Name="SysOs" Text="OS: Loading..." Foreground="#AEB9CC" Margin="0,4" FontSize="14" TextTrimming="CharacterEllipsis" /><TextBlock x:Name="SysCpu" Text="CPU: Loading..." Foreground="#AEB9CC" Margin="0,4" FontSize="14" TextTrimming="CharacterEllipsis" /><TextBlock x:Name="SysRam" Text="RAM: Loading..." Foreground="#AEB9CC" Margin="0,4" FontSize="14" TextTrimming="CharacterEllipsis" /><TextBlock x:Name="SysHwid" Text="HWID: Loading..." Foreground="#AEB9CC" Margin="0,4" FontSize="14" TextTrimming="CharacterEllipsis" /></StackPanel></Border><!-- QUICK APPLY --><Border Grid.Row="0" Grid.Column="1" Background="{StaticResource CardGradient}" CornerRadius="12" Margin="15,0,0,15" Padding="25" BorderThickness="1" BorderBrush="#2C3445"><Border.Effect><DropShadowEffect BlurRadius="15" ShadowDepth="4" Opacity="0.1" Direction="270" Color="Black" /></Border.Effect><StackPanel><StackPanel Orientation="Horizontal" Margin="0,0,0,20"><Rectangle Width="4" Height="18" Fill="{StaticResource AccentGradient}" Margin="0,0,12,0" RadiusX="2" RadiusY="2" /><TextBlock Text="ตั้งค่าด่วน (แนะนำ)" Foreground="#F2F4F8" FontWeight="Bold" FontSize="16" /></StackPanel><TextBlock Text="เปิดใช้งาน: CPU Maximum + QoS FiveM + Timer ON" Foreground="#AEB9CC" Margin="0,0,0,20" FontSize="14" /><Button x:Name="BtnApplyRec" Style="{StaticResource PremiumButton}" Height="45"><StackPanel Orientation="Horizontal"><TextBlock FontFamily="Segoe MDL2 Assets" Text="" FontSize="16" Margin="0,0,8,0" VerticalAlignment="Center" /><TextBlock Text="APPLY RECOMMENDED" VerticalAlignment="Center" FontWeight="Bold" /></StackPanel></Button></StackPanel></Border><!-- STATUS --><Border Grid.Row="1" Grid.ColumnSpan="2" Background="{StaticResource CardGradient}" CornerRadius="12" Margin="0,0,0,15" Padding="25" BorderThickness="1" BorderBrush="#2C3445"><Border.Effect><DropShadowEffect BlurRadius="15" ShadowDepth="4" Opacity="0.1" Direction="270" Color="Black" /></Border.Effect><Grid><Grid.ColumnDefinitions><ColumnDefinition Width="*" /><ColumnDefinition Width="Auto" /></Grid.ColumnDefinitions><StackPanel Grid.Column="0"><StackPanel Orientation="Horizontal" Margin="0,0,0,20"><Rectangle Width="4" Height="18" Fill="{StaticResource AccentGradient}" Margin="0,0,12,0" RadiusX="2" RadiusY="2" /><TextBlock Text="STATUS" Foreground="#F2F4F8" FontWeight="Bold" FontSize="16" /></StackPanel><WrapPanel><TextBlock x:Name="StatusPriority" Text="Win32PrioritySeparation: Unknown" Foreground="#AEB9CC" Margin="0,0,35,8" FontSize="14" /><TextBlock x:Name="StatusQos" Text="QoS FiveM: Unknown" Foreground="#AEB9CC" Margin="0,0,35,8" FontSize="14" /><TextBlock x:Name="StatusTimer" Text="Timer Service: Unknown" Foreground="#AEB9CC" Margin="0,0,35,8" FontSize="14" /><TextBlock x:Name="StatusPlan" Text="Power Plan: Unknown" Foreground="#AEB9CC" Margin="0,0,35,8" FontSize="14" /></WrapPanel></StackPanel><Button x:Name="BtnTutorialDashboard" Grid.Column="1" Style="{StaticResource SecondaryButton}" Width="160" Height="42" VerticalAlignment="Center" Margin="15,0,0,0"><StackPanel Orientation="Horizontal"><TextBlock FontFamily="Segoe MDL2 Assets" Text="" FontSize="14" Margin="0,0,8,0" VerticalAlignment="Center" Foreground="#A1AEC3" /><TextBlock Text="วิดีโอสอนใช้งาน" VerticalAlignment="Center" FontWeight="Bold" Foreground="#A1AEC3" /></StackPanel></Button></Grid></Border></Grid></Grid><!-- VIEW 2: CPU / PRIORITY --><Grid x:Name="ViewCPU" Visibility="Collapsed"><Grid.RowDefinitions><RowDefinition Height="Auto" /><RowDefinition Height="*" /></Grid.RowDefinitions><StackPanel Grid.Row="0" Margin="0,0,0,25"><TextBlock Text="CPU / Priority" Foreground="#F2F4F8" FontSize="30" FontWeight="Bold" /><TextBlock Text="ค่าเริ่มต้นระบบ (ยังไม่ปรับแต่ง)" Foreground="#F2F4F8" FontSize="15" Margin="0,6,0,0" /></StackPanel><ScrollViewer Grid.Row="1" VerticalScrollBarVisibility="Auto"><StackPanel><Border Background="{StaticResource CardGradient}" CornerRadius="12" Margin="0,0,0,20" Padding="30" BorderThickness="1" BorderBrush="#2C3445"><StackPanel><StackPanel Orientation="Horizontal" Margin="0,0,0,20"><Rectangle Width="4" Height="18" Fill="{StaticResource AccentGradient}" Margin="0,0,12,0" RadiusX="2" RadiusY="2" /><TextBlock Text="Win32 Priority Separation" Foreground="#F2F4F8" FontWeight="Bold" FontSize="16" /></StackPanel><TextBlock Text="ปรับระดับความสำคัญ Win32 Priority Separation สำหรับ FiveM" Foreground="#AEB9CC" Margin="0,0,0,20" /><UniformGrid Columns="3" Rows="2" HorizontalAlignment="Stretch"><Button x:Name="BtnCpu26" Style="{StaticResource SecondaryButton}" Height="65" Margin="6"><StackPanel><TextBlock Text="BALANCED" FontSize="15" FontWeight="Bold" HorizontalAlignment="Center" Foreground="#F2F4F8" /><TextBlock Text="สมดุล (ใช้งานทั่วไป &amp; เล่นเกม)" FontSize="11" Foreground="#AEB9CC" HorizontalAlignment="Center" Margin="0,2,0,0" /></StackPanel></Button><Button x:Name="BtnCpu28" Style="{StaticResource PremiumButton}" Height="65" Margin="6"><StackPanel><TextBlock Text="RECOMMENDED" FontSize="15" FontWeight="Bold" HorizontalAlignment="Center" Foreground="White" /><TextBlock Text="สมดุล (ดีที่สุดสำหรับ FiveM)" FontSize="11" Foreground="#30394C" HorizontalAlignment="Center" Margin="0,2,0,0" /></StackPanel></Button><Button x:Name="BtnCpu2A" Style="{StaticResource SecondaryButton}" Height="65" Margin="6"><StackPanel><TextBlock Text="MAXIMUM" FontSize="15" FontWeight="Bold" HorizontalAlignment="Center" Foreground="#F2F4F8" /><TextBlock Text="สูงสุด (รีด FPS สูงสุด)" FontSize="11" Foreground="#AEB9CC" HorizontalAlignment="Center" Margin="0,2,0,0" /></StackPanel></Button><Button x:Name="BtnCpu16" Style="{StaticResource SecondaryButton}" Height="65" Margin="6"><StackPanel><TextBlock Text="STREAMING" FontSize="15" FontWeight="Bold" HorizontalAlignment="Center" Foreground="#F2F4F8" /><TextBlock Text="สตรีมมิ่ง (ทำงานหลายอย่าง &amp; สตรีม OBS)" FontSize="11" Foreground="#AEB9CC" HorizontalAlignment="Center" Margin="0,2,0,0" /></StackPanel></Button><Button x:Name="BtnCpu18" Style="{StaticResource SecondaryButton}" Height="65" Margin="6"><StackPanel><TextBlock Text="GAMING" FontSize="15" FontWeight="Bold" HorizontalAlignment="Center" Foreground="#F2F4F8" /><TextBlock Text="เล่นเกม (เฟรมเรตเสถียร)" FontSize="11" Foreground="#AEB9CC" HorizontalAlignment="Center" Margin="0,2,0,0" /></StackPanel></Button><Button x:Name="BtnCpuDef" Style="{StaticResource SecondaryButton}" Height="65" Margin="6"><StackPanel><TextBlock Text="Default" FontSize="17" FontWeight="Bold" HorizontalAlignment="Center" Foreground="#F2F4F8" /><TextBlock Text="ค่าเริ่มต้น Windows" FontSize="12" Foreground="#AEB9CC" HorizontalAlignment="Center" Margin="0,2,0,0" /></StackPanel></Button></UniformGrid></StackPanel></Border><Border Background="{StaticResource CardGradient}" CornerRadius="12" Margin="0,0,0,20" Padding="30" BorderThickness="1" BorderBrush="#2C3445"><StackPanel><StackPanel Orientation="Horizontal" Margin="0,0,0,20"><Rectangle Width="4" Height="18" Fill="{StaticResource AccentGradient}" Margin="0,0,12,0" RadiusX="2" RadiusY="2" /><TextBlock Text="CPU Core Optimization" Foreground="#F2F4F8" FontWeight="Bold" FontSize="16" /></StackPanel><TextBlock Text="ปลดล็อคการทำงานคอร์ CPU ทั้งหมด (Unpark Cores)" Foreground="#AEB9CC" Margin="0,0,0,20" /><StackPanel Orientation="Horizontal"><Button x:Name="BtnUnpark" Style="{StaticResource PremiumButton}" Width="240" Height="55" Margin="0,0,15,0"><StackPanel Orientation="Horizontal"><TextBlock FontFamily="Segoe MDL2 Assets" Text="" FontSize="18" Margin="0,0,10,0" VerticalAlignment="Center" /><TextBlock Text="UNPARK ALL CORES" FontWeight="Bold" FontSize="14" VerticalAlignment="Center" /></StackPanel></Button><Button x:Name="BtnPark" Style="{StaticResource SecondaryButton}" Width="200" Height="55"><StackPanel Orientation="Horizontal"><TextBlock FontFamily="Segoe MDL2 Assets" Text="" FontSize="18" Margin="0,0,10,0" VerticalAlignment="Center" Foreground="#AEB9CC" /><TextBlock Text="PARK DEFAULT" FontWeight="Bold" FontSize="14" VerticalAlignment="Center" Foreground="#A1AEC3" /></StackPanel></Button></StackPanel></StackPanel></Border></StackPanel></ScrollViewer></Grid><!-- VIEW 3: INPUT --><Grid x:Name="ViewInput" Visibility="Collapsed"><Grid.RowDefinitions><RowDefinition Height="Auto" /><RowDefinition Height="*" /></Grid.RowDefinitions><StackPanel Grid.Row="0" Margin="0,0,0,30"><TextBlock Text="Input (Mouse/Keyboard)" Foreground="#F2F4F8" FontSize="30" FontWeight="Bold" /><TextBlock Text="ตั้งค่าลดความหน่วง (Lowest Input Lag)" Foreground="#F2F4F8" FontSize="15" Margin="0,6,0,0" /></StackPanel><Border Grid.Row="1" Background="{StaticResource CardGradient}" CornerRadius="12" Padding="30" BorderThickness="1" BorderBrush="#2C3445" VerticalAlignment="Top"><StackPanel><StackPanel Orientation="Horizontal" Margin="0,0,0,20"><Rectangle Width="4" Height="18" Fill="{StaticResource AccentGradient}" Margin="0,0,12,0" RadiusX="2" RadiusY="2" /><TextBlock Text="Mouse Fix &amp; Keyboard Response" Foreground="#F2F4F8" FontWeight="Bold" FontSize="16" /></StackPanel><TextBlock Text="ปิดการจำลองเมาส์ของ Windows (Mouse Acceleration) เพื่อการเล็งที่แม่นยำขึ้น" Foreground="#AEB9CC" Margin="0,0,0,25" TextWrapping="Wrap" /><Button x:Name="BtnInputMouse" Style="{StaticResource PremiumButton}" Height="55" Margin="0,0,0,15"><StackPanel Orientation="Horizontal"><TextBlock FontFamily="Segoe MDL2 Assets" Text="" FontSize="18" Margin="0,0,10,0" VerticalAlignment="Center" /><TextBlock Text="APPLY MOUSE &amp; KEYBOARD TWEAK" FontWeight="Bold" FontSize="14" VerticalAlignment="Center" /></StackPanel></Button><Button x:Name="BtnInputRestore" Style="{StaticResource SecondaryButton}" Height="50"><StackPanel Orientation="Horizontal"><TextBlock FontFamily="Segoe MDL2 Assets" Text="" FontSize="18" Margin="0,0,10,0" VerticalAlignment="Center" Foreground="#AEB9CC" /><TextBlock Text="RESTORE INPUT DEFAULTS" FontWeight="Bold" FontSize="14" VerticalAlignment="Center" Foreground="#A1AEC3" /></StackPanel></Button></StackPanel></Border></Grid><!-- VIEW 4: NETWORK --><Grid x:Name="ViewNetwork" Visibility="Collapsed"><Grid.RowDefinitions><RowDefinition Height="Auto" /><RowDefinition Height="*" /></Grid.RowDefinitions><StackPanel Grid.Row="0" Margin="0,0,0,30"><TextBlock Text="Network (QoS / TCP)" Foreground="#F2F4F8" FontSize="30" FontWeight="Bold" /><TextBlock Text="ตั้งค่าลดปิงและความหน่วง (Ping &amp; Latency)" Foreground="#F2F4F8" FontSize="15" Margin="0,6,0,0" /></StackPanel><Border Grid.Row="1" Background="{StaticResource CardGradient}" CornerRadius="12" Padding="30" BorderThickness="1" BorderBrush="#2C3445" VerticalAlignment="Top"><StackPanel><StackPanel Orientation="Horizontal" Margin="0,0,0,20"><Rectangle Width="4" Height="18" Fill="{StaticResource AccentGradient}" Margin="0,0,12,0" RadiusX="2" RadiusY="2" /><TextBlock Text="TCP/IP &amp; QoS Settings" Foreground="#F2F4F8" FontWeight="Bold" FontSize="16" /></StackPanel><TextBlock Text="ปรับแต่ง Network Adapter, DNS และ TCP Settings เพื่อการเล่นเกมที่ลื่นไหลที่สุด" Foreground="#AEB9CC" Margin="0,0,0,25" TextWrapping="Wrap" /><Button x:Name="BtnNetTweak" Style="{StaticResource PremiumButton}" Height="55" Margin="0,0,0,15"><StackPanel Orientation="Horizontal"><TextBlock FontFamily="Segoe MDL2 Assets" Text="" FontSize="18" Margin="0,0,10,0" VerticalAlignment="Center" /><TextBlock Text="APPLY NETWORK TWEAK (GAMING)" FontWeight="Bold" FontSize="14" VerticalAlignment="Center" /></StackPanel></Button><Button x:Name="BtnNetFlush" Style="{StaticResource SecondaryButton}" Height="50" Margin="0,0,0,15"><StackPanel Orientation="Horizontal"><TextBlock FontFamily="Segoe MDL2 Assets" Text="" FontSize="18" Margin="0,0,10,0" VerticalAlignment="Center" Foreground="#AEB9CC" /><TextBlock Text="FLUSH DNS &amp; RESET IP" FontWeight="Bold" FontSize="14" VerticalAlignment="Center" Foreground="#A1AEC3" /></StackPanel></Button><Button x:Name="BtnNetRestore" Style="{StaticResource SecondaryButton}" Height="50"><StackPanel Orientation="Horizontal"><TextBlock FontFamily="Segoe MDL2 Assets" Text="" FontSize="18" Margin="0,0,10,0" VerticalAlignment="Center" Foreground="#AEB9CC" /><TextBlock Text="RESTORE NETWORK DEFAULTS" FontWeight="Bold" FontSize="14" VerticalAlignment="Center" Foreground="#A1AEC3" /></StackPanel></Button></StackPanel></Border></Grid><!-- VIEW 5: POWER / TIMER --><Grid x:Name="ViewPower" Visibility="Collapsed"><Grid.RowDefinitions><RowDefinition Height="Auto" /><RowDefinition Height="*" /></Grid.RowDefinitions><StackPanel Grid.Row="0" Margin="0,0,0,30"><TextBlock Text="Power / Timer" Foreground="#F2F4F8" FontSize="30" FontWeight="Bold" /><TextBlock Text="การตั้งค่าและปรับแต่งระบบเพิ่มเติม" Foreground="#F2F4F8" FontSize="15" Margin="0,6,0,0" /></StackPanel><StackPanel Grid.Row="1"><Border Background="{StaticResource CardGradient}" CornerRadius="12" Padding="30" BorderThickness="1" BorderBrush="#2C3445" Margin="0,0,0,20"><StackPanel><StackPanel Orientation="Horizontal" Margin="0,0,0,20"><Rectangle Width="4" Height="18" Fill="{StaticResource AccentGradient}" Margin="0,0,12,0" RadiusX="2" RadiusY="2" /><TextBlock Text="CPU Priority (FiveM)" Foreground="#F2F4F8" FontWeight="Bold" FontSize="16" /></StackPanel><TextBlock Text="เลือกระดับความสำคัญสำหรับโปรแกรม FiveM" Foreground="#AEB9CC" Margin="0,0,0,20" /><Button x:Name="BtnPowerImport" Style="{StaticResource PremiumButton}" Height="55"><StackPanel Orientation="Horizontal"><TextBlock FontFamily="Segoe MDL2 Assets" Text="" FontSize="18" Margin="0,0,10,0" VerticalAlignment="Center" /><TextBlock Text="IMPORT &amp; APPLY POWER PLAN" FontWeight="Bold" FontSize="14" VerticalAlignment="Center" /></StackPanel></Button></StackPanel></Border><Border Background="{StaticResource CardGradient}" CornerRadius="12" Padding="30" BorderThickness="1" BorderBrush="#2C3445"><StackPanel><StackPanel Orientation="Horizontal" Margin="0,0,0,20"><Rectangle Width="4" Height="18" Fill="{StaticResource AccentGradient}" Margin="0,0,12,0" RadiusX="2" RadiusY="2" /><TextBlock Text="Timer Resolution" Foreground="#F2F4F8" FontWeight="Bold" FontSize="16" /></StackPanel><TextBlock Text="ปรับตั้งค่า HPET และ RTC Timer เพื่อลดความหน่วงของระบบ" Foreground="#AEB9CC" Margin="0,0,0,20" /><StackPanel Orientation="Horizontal"><Button x:Name="BtnTimerEnable" Style="{StaticResource PremiumButton}" Width="240" Height="55" Margin="0,0,15,0"><StackPanel Orientation="Horizontal"><TextBlock FontFamily="Segoe MDL2 Assets" Text="" FontSize="18" Margin="0,0,10,0" VerticalAlignment="Center" /><TextBlock Text="ENABLE CUSTOM TIMER" FontWeight="Bold" FontSize="14" VerticalAlignment="Center" /></StackPanel></Button><Button x:Name="BtnTimerDisable" Style="{StaticResource SecondaryButton}" Width="200" Height="55"><StackPanel Orientation="Horizontal"><TextBlock FontFamily="Segoe MDL2 Assets" Text="" FontSize="18" Margin="0,0,10,0" VerticalAlignment="Center" Foreground="#AEB9CC" /><TextBlock Text="DISABLE TIMER" FontWeight="Bold" FontSize="14" VerticalAlignment="Center" Foreground="#A1AEC3" /></StackPanel></Button></StackPanel></StackPanel></Border></StackPanel></Grid><!-- VIEW 6: TOOLS --><Grid x:Name="ViewTools" Visibility="Collapsed"><Grid.RowDefinitions><RowDefinition Height="Auto" /><RowDefinition Height="*" /></Grid.RowDefinitions><StackPanel Grid.Row="0" Margin="0,0,0,30"><TextBlock Text="เครื่องมือ (Tools)" Foreground="#F2F4F8" FontSize="30" FontWeight="Bold" /><TextBlock Text="เครื่องมือจัดการระบบ และทำความสะอาดหน่วยความจำ (RAM Cleaner)" Foreground="#F2F4F8" FontSize="15" Margin="0,6,0,0" /></StackPanel><Border Grid.Row="1" Background="{StaticResource CardGradient}" CornerRadius="12" Padding="30" BorderThickness="1" BorderBrush="#2C3445" VerticalAlignment="Top"><UniformGrid Columns="2" Rows="2"><Button x:Name="BtnMsiUtil" Style="{StaticResource PremiumButton}" Height="70" Margin="10"><StackPanel><TextBlock FontFamily="Segoe MDL2 Assets" Text="" FontSize="20" HorizontalAlignment="Center" Margin="0,0,0,4" /><TextBlock Text="MSI UTILITY V3" FontWeight="Bold" FontSize="13" HorizontalAlignment="Center" /></StackPanel></Button><Button x:Name="BtnDeviceCleanup" Style="{StaticResource SecondaryButton}" Height="70" Margin="10"><StackPanel><TextBlock FontFamily="Segoe MDL2 Assets" Text="" FontSize="20" Foreground="#AEB9CC" HorizontalAlignment="Center" Margin="0,0,0,4" /><TextBlock Text="DEVICE CLEANUP" FontWeight="Bold" FontSize="13" Foreground="#A1AEC3" HorizontalAlignment="Center" /></StackPanel></Button><Button x:Name="BtnMemCleaner" Style="{StaticResource SecondaryButton}" Height="70" Margin="10"><StackPanel><TextBlock FontFamily="Segoe MDL2 Assets" Text="" FontSize="20" Foreground="#AEB9CC" HorizontalAlignment="Center" Margin="0,0,0,4" /><TextBlock Text="MEMORY CLEANER" FontWeight="Bold" FontSize="13" Foreground="#A1AEC3" HorizontalAlignment="Center" /></StackPanel></Button><Button x:Name="BtnWinUtil" Style="{StaticResource SecondaryButton}" Height="70" Margin="10"><StackPanel><TextBlock FontFamily="Segoe MDL2 Assets" Text="" FontSize="20" Foreground="#AEB9CC" HorizontalAlignment="Center" Margin="0,0,0,4" /><TextBlock Text="WIN UTIL TWEAKS" FontWeight="Bold" FontSize="13" Foreground="#A1AEC3" HorizontalAlignment="Center" /></StackPanel></Button></UniformGrid></Border></Grid><!-- VIEW 7: RESTORE --><Grid x:Name="ViewRestore" Visibility="Collapsed"><Grid.RowDefinitions><RowDefinition Height="Auto" /><RowDefinition Height="*" /></Grid.RowDefinitions><StackPanel Grid.Row="0" Margin="0,0,0,30"><TextBlock Text="คืนค่าเดิม (Restore)" Foreground="#F2F4F8" FontSize="30" FontWeight="Bold" /><TextBlock Text="สำรองและคืนค่าระบบ" Foreground="#F2F4F8" FontSize="15" Margin="0,6,0,0" /></StackPanel><Border Grid.Row="1" Background="#191E2B" CornerRadius="12" Padding="30" BorderThickness="1" BorderBrush="#1f1f1f" VerticalAlignment="Top"><StackPanel><StackPanel Orientation="Horizontal" Margin="0,0,0,20"><Rectangle Width="4" Height="18" Fill="#131722" Margin="0,0,12,0" RadiusX="2" RadiusY="2" /><TextBlock Text="System Restore &amp; Backup" Foreground="#F2F4F8" FontWeight="Bold" FontSize="16" /></StackPanel><TextBlock Text="คืนค่าการตั้งค่าทั้งหมดกลับไปเป็นค่าเริ่มต้นของ Windows" Foreground="#AEB9CC" Margin="0,0,0,25" TextWrapping="Wrap" /><Button x:Name="BtnRestoreAll" Height="55" Margin="0,0,0,15"><Button.Style><Style TargetType="Button" BasedOn="{StaticResource SecondaryButton}"><Setter Property="BorderBrush" Value="#2a2a2a" /><Style.Triggers><Trigger Property="IsMouseOver" Value="True"><Setter Property="Background" Value="#1a1a1a" /></Trigger></Style.Triggers></Style></Button.Style><StackPanel Orientation="Horizontal"><TextBlock FontFamily="Segoe MDL2 Assets" Text="" FontSize="18" Margin="0,0,10,0" VerticalAlignment="Center" Foreground="#A1AEC3" /><TextBlock Text="RESTORE ALL SETTINGS TO DEFAULT" FontWeight="Bold" FontSize="14" VerticalAlignment="Center" Foreground="#A1AEC3" /></StackPanel></Button><Button x:Name="BtnRestorePoint" Style="{StaticResource SecondaryButton}" Height="50"><StackPanel Orientation="Horizontal"><TextBlock FontFamily="Segoe MDL2 Assets" Text="" FontSize="18" Margin="0,0,10,0" VerticalAlignment="Center" Foreground="#AEB9CC" /><TextBlock Text="CREATE SYSTEM RESTORE POINT" FontWeight="Bold" FontSize="14" VerticalAlignment="Center" Foreground="#A1AEC3" /></StackPanel></Button></StackPanel></Border></Grid><Grid xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" x:Name="ViewFiveM" Visibility="Collapsed"><StackPanel><TextBlock Text="FiveM / MTU" Foreground="#F2F4F8" FontSize="30" FontWeight="Bold" /><TextBlock Text="ตั้งค่าเครือข่าย FiveM ในไฟล์ fivem.cfg" Foreground="#AEB9CC" FontSize="15" Margin="0,6,0,24" /><Border Background="{StaticResource CardGradient}" CornerRadius="16" Padding="30" BorderBrush="#42305E" BorderThickness="1"><StackPanel><TextBlock Text="CITIZENFX NETWORK" Foreground="#BE9AFF" FontSize="12" FontWeight="SemiBold" /><TextBlock Text="1080" Foreground="#F2F4F8" FontSize="64" FontWeight="Bold" Margin="0,12,0,0" /><TextBlock Text="net_maxMtu" Foreground="#CDB8F4" FontSize="18" FontFamily="Consolas" /><TextBlock Text="ปิด FiveM ก่อนกดบันทึก แล้วเปิดเกมใหม่เพื่อใช้ค่า" Foreground="#AEB9CC" Margin="0,20,0,8" TextWrapping="Wrap" /><TextBlock Text="%APPDATA%\CitizenFX\fivem.cfg" Foreground="#AEB9CC" FontFamily="Consolas" FontSize="13" Margin="0,0,0,24" /><Button x:Name="BtnFiveM1080" Style="{StaticResource PremiumButton}" Height="56" Content="ตั้งค่า MTU เป็น 1080" /><TextBlock x:Name="FiveMResult" Text="สำรองไฟล์เดิมอัตโนมัติก่อนแก้ไข" Foreground="#AEB9CC" Margin="0,18,0,0" TextWrapping="Wrap" /></StackPanel></Border></StackPanel></Grid></Grid></Grid></Grid><!-- AUTH CONTAINER --><Grid x:Name="AuthContainer" Grid.Row="1" Visibility="Visible"><!-- Dark Overlay --><Border Background="#66000000" /><!-- Login Box --><Border Width="400" Height="520" CornerRadius="24" HorizontalAlignment="Center" VerticalAlignment="Center" BorderThickness="1"><Border.Background><LinearGradientBrush StartPoint="0,0" EndPoint="1,1"><GradientStop Color="#FA191E2B" Offset="0.0" /><GradientStop Color="#FA10141E" Offset="1.0" /></LinearGradientBrush></Border.Background><Border.BorderBrush><LinearGradientBrush StartPoint="0,0" EndPoint="1,1"><GradientStop Color="#44ffffff" Offset="0.0" /><GradientStop Color="#11ffffff" Offset="1.0" /></LinearGradientBrush></Border.BorderBrush><Border.Effect><DropShadowEffect BlurRadius="50" ShadowDepth="15" Color="#000000" Opacity="0.8" /></Border.Effect><Grid Margin="35,40,35,30"><Grid.RowDefinitions><RowDefinition Height="Auto" /><RowDefinition Height="Auto" /><RowDefinition Height="Auto" /><RowDefinition Height="*" /></Grid.RowDefinitions><!-- Logo / Header --><StackPanel Grid.Row="0" HorizontalAlignment="Center" Margin="0,0,0,35"><!-- Minimalist Avatar --><Grid HorizontalAlignment="Center" Margin="0,0,0,15" Width="76" Height="76" RenderTransformOrigin="0.5,0.5"><Grid.RenderTransform><ScaleTransform ScaleX="1" ScaleY="1" /></Grid.RenderTransform><Grid.Triggers><EventTrigger RoutedEvent="FrameworkElement.Loaded"><BeginStoryboard><Storyboard RepeatBehavior="Forever" AutoReverse="True"><DoubleAnimation Storyboard.TargetProperty="(UIElement.RenderTransform).(ScaleTransform.ScaleX)" From="1.0" To="1.06" Duration="0:0:2.0"><DoubleAnimation.EasingFunction><SineEase EasingMode="EaseInOut" /></DoubleAnimation.EasingFunction></DoubleAnimation><DoubleAnimation Storyboard.TargetProperty="(UIElement.RenderTransform).(ScaleTransform.ScaleY)" From="1.0" To="1.06" Duration="0:0:2.0"><DoubleAnimation.EasingFunction><SineEase EasingMode="EaseInOut" /></DoubleAnimation.EasingFunction></DoubleAnimation></Storyboard></BeginStoryboard></EventTrigger></Grid.Triggers><!-- Minimalist Background Drop Shadow --><Ellipse Width="76" Height="76" Fill="#05000000"><Ellipse.Effect><DropShadowEffect BlurRadius="20" ShadowDepth="0" Color="#000000" Opacity="0.6" /></Ellipse.Effect></Ellipse><!-- Profile Image Overlay with Original Thin Stroke --><Ellipse x:Name="AuthProfileImage" Width="70" Height="70" Fill="#151515" Stroke="#44ffffff" StrokeThickness="1" RenderOptions.BitmapScalingMode="HighQuality" VerticalAlignment="Center" HorizontalAlignment="Center" /></Grid><TextBlock Text="Redpro Setting V2" Foreground="#F2F4F8" FontSize="20" FontWeight="Light" HorizontalAlignment="Center"><TextBlock.Effect><DropShadowEffect BlurRadius="5" ShadowDepth="0" Color="#000000" Opacity="0.8" /></TextBlock.Effect></TextBlock><TextBlock Text="SYSTEM V2.0" Foreground="#F2F4F8" FontSize="10" FontWeight="SemiBold" HorizontalAlignment="Center" Margin="0,4,0,0" /></StackPanel><!-- View: Login --><StackPanel x:Name="AuthLoginView" Grid.Row="1" Visibility="Visible"><TextBlock Text="HWID (Hardware ID)" Foreground="#999999" FontSize="11" Margin="5,0,0,5" FontWeight="SemiBold" /><Border Background="#10ffffff" BorderBrush="#22ffffff" BorderThickness="1" CornerRadius="10" Padding="15,12" Margin="0,0,0,15"><TextBox x:Name="TxtHWID" IsReadOnly="True" Background="Transparent" Foreground="#A1AEC3" CaretBrush="White" BorderThickness="0" FontFamily="Consolas" FontSize="12" Margin="0" /></Border><TextBlock Text="LICENSE KEY" Foreground="#999999" FontSize="11" Margin="5,0,0,5" FontWeight="SemiBold" /><Border Background="#10ffffff" BorderBrush="#22ffffff" BorderThickness="1" CornerRadius="10" Padding="15,12" Margin="0,0,0,30"><Grid><PasswordBox x:Name="TxtLoginPassword" Background="Transparent" Foreground="#F2F4F8" CaretBrush="White" BorderThickness="0" FontSize="14" Margin="0,0,30,0" VerticalContentAlignment="Center" /><TextBox x:Name="TxtLoginPasswordVisible" Visibility="Collapsed" Background="Transparent" Foreground="#F2F4F8" CaretBrush="White" BorderThickness="0" FontSize="14" Margin="0,0,30,0" VerticalContentAlignment="Center" /><ToggleButton x:Name="BtnToggleLoginPass" Width="24" Height="24" HorizontalAlignment="Right" Background="Transparent" BorderThickness="0" Cursor="Hand"><ToggleButton.Template><ControlTemplate TargetType="ToggleButton"><Grid VerticalAlignment="Center" HorizontalAlignment="Center"><TextBlock FontFamily="Segoe MDL2 Assets" x:Name="Icon" Text="" FontSize="14" Foreground="#999999" /><Line x:Name="Slash" X1="3" Y1="13" X2="12" Y2="1" Stroke="#999999" StrokeThickness="1.5" /></Grid><ControlTemplate.Triggers><Trigger Property="IsChecked" Value="True"><Setter TargetName="Slash" Property="Visibility" Value="Collapsed" /><Setter TargetName="Icon" Property="Foreground" Value="White" /></Trigger><Trigger Property="IsMouseOver" Value="True"><Setter TargetName="Icon" Property="Foreground" Value="#131722" /><Setter TargetName="Slash" Property="Stroke" Value="#131722" /></Trigger></ControlTemplate.Triggers></ControlTemplate></ToggleButton.Template></ToggleButton></Grid></Border><Button x:Name="BtnLogin" Content="LOGIN" Height="45" Foreground="White" FontWeight="SemiBold" FontSize="14" Cursor="Hand" Margin="0,0,0,20"><Button.Template><ControlTemplate TargetType="Button"><Border x:Name="bg" CornerRadius="10" BorderBrush="#33ffffff" BorderThickness="1"><Border.Background><LinearGradientBrush StartPoint="0,0" EndPoint="1,1"><GradientStop Color="#8B5CF6" Offset="0.0" /><GradientStop Color="#8B5CF6" Offset="1.0" /></LinearGradientBrush></Border.Background><ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center" /></Border><ControlTemplate.Triggers><Trigger Property="IsMouseOver" Value="True"><Setter TargetName="bg" Property="Background"><Setter.Value><LinearGradientBrush StartPoint="0,0" EndPoint="1,1"><GradientStop Color="#8B5CF6" Offset="0.0" /><GradientStop Color="#8B5CF6" Offset="1.0" /></LinearGradientBrush></Setter.Value></Setter><Setter TargetName="bg" Property="BorderBrush" Value="#88ffffff" /></Trigger></ControlTemplate.Triggers></ControlTemplate></Button.Template></Button><TextBlock Foreground="#A1AEC3" FontSize="11" HorizontalAlignment="Center" Text="Enter your KeyAuth license key to activate." /></StackPanel><!-- View: Register --><StackPanel x:Name="AuthRegisterView" Grid.Row="1" Visibility="Collapsed"><TextBlock Text="CREATE PASSWORD" Foreground="#999999" FontSize="11" Margin="5,0,0,5" FontWeight="SemiBold" /><Border Background="#10ffffff" BorderBrush="#22ffffff" BorderThickness="1" CornerRadius="10" Padding="15,12" Margin="0,0,0,15"><Grid><PasswordBox x:Name="TxtRegPassword" Background="Transparent" Foreground="#F2F4F8" CaretBrush="White" BorderThickness="0" FontSize="14" Margin="0,0,30,0" VerticalContentAlignment="Center" /><TextBox x:Name="TxtRegPasswordVisible" Visibility="Collapsed" Background="Transparent" Foreground="#F2F4F8" CaretBrush="White" BorderThickness="0" FontSize="14" Margin="0,0,30,0" VerticalContentAlignment="Center" /><ToggleButton x:Name="BtnToggleRegPass" Width="24" Height="24" HorizontalAlignment="Right" Background="Transparent" BorderThickness="0" Cursor="Hand"><ToggleButton.Template><ControlTemplate TargetType="ToggleButton"><Grid VerticalAlignment="Center" HorizontalAlignment="Center"><TextBlock FontFamily="Segoe MDL2 Assets" x:Name="Icon" Text="" FontSize="14" Foreground="#999999" /><Line x:Name="Slash" X1="3" Y1="13" X2="12" Y2="1" Stroke="#999999" StrokeThickness="1.5" /></Grid><ControlTemplate.Triggers><Trigger Property="IsChecked" Value="True"><Setter TargetName="Slash" Property="Visibility" Value="Collapsed" /><Setter TargetName="Icon" Property="Foreground" Value="White" /></Trigger><Trigger Property="IsMouseOver" Value="True"><Setter TargetName="Icon" Property="Foreground" Value="#131722" /><Setter TargetName="Slash" Property="Stroke" Value="#131722" /></Trigger></ControlTemplate.Triggers></ControlTemplate></ToggleButton.Template></ToggleButton></Grid></Border><TextBlock Text="CONFIRM PASSWORD" Foreground="#999999" FontSize="11" Margin="5,0,0,5" FontWeight="SemiBold" /><Border Background="#10ffffff" BorderBrush="#22ffffff" BorderThickness="1" CornerRadius="10" Padding="15,12" Margin="0,0,0,30"><Grid><PasswordBox x:Name="TxtRegPasswordConfirm" Background="Transparent" Foreground="#F2F4F8" CaretBrush="White" BorderThickness="0" FontSize="14" Margin="0,0,30,0" VerticalContentAlignment="Center" /><TextBox x:Name="TxtRegPasswordConfirmVisible" Visibility="Collapsed" Background="Transparent" Foreground="#F2F4F8" CaretBrush="White" BorderThickness="0" FontSize="14" Margin="0,0,30,0" VerticalContentAlignment="Center" /><ToggleButton x:Name="BtnToggleRegPassConfirm" Width="24" Height="24" HorizontalAlignment="Right" Background="Transparent" BorderThickness="0" Cursor="Hand"><ToggleButton.Template><ControlTemplate TargetType="ToggleButton"><Grid VerticalAlignment="Center" HorizontalAlignment="Center"><TextBlock FontFamily="Segoe MDL2 Assets" x:Name="Icon" Text="" FontSize="14" Foreground="#999999" /><Line x:Name="Slash" X1="3" Y1="13" X2="12" Y2="1" Stroke="#999999" StrokeThickness="1.5" /></Grid><ControlTemplate.Triggers><Trigger Property="IsChecked" Value="True"><Setter TargetName="Slash" Property="Visibility" Value="Collapsed" /><Setter TargetName="Icon" Property="Foreground" Value="White" /></Trigger><Trigger Property="IsMouseOver" Value="True"><Setter TargetName="Icon" Property="Foreground" Value="#131722" /><Setter TargetName="Slash" Property="Stroke" Value="#131722" /></Trigger></ControlTemplate.Triggers></ControlTemplate></ToggleButton.Template></ToggleButton></Grid></Border><Button x:Name="BtnRegister" Content="CREATE ACCOUNT" Height="45" Foreground="White" FontWeight="SemiBold" FontSize="14" Cursor="Hand" Margin="0,0,0,20"><Button.Template><ControlTemplate TargetType="Button"><Border x:Name="bg" CornerRadius="10" BorderBrush="#33ffffff" BorderThickness="1"><Border.Background><LinearGradientBrush StartPoint="0,0" EndPoint="1,1"><GradientStop Color="#8B5CF6" Offset="0.0" /><GradientStop Color="#8B5CF6" Offset="1.0" /></LinearGradientBrush></Border.Background><ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center" /></Border><ControlTemplate.Triggers><Trigger Property="IsMouseOver" Value="True"><Setter TargetName="bg" Property="Background"><Setter.Value><LinearGradientBrush StartPoint="0,0" EndPoint="1,1"><GradientStop Color="#8B5CF6" Offset="0.0" /><GradientStop Color="#8B5CF6" Offset="1.0" /></LinearGradientBrush></Setter.Value></Setter><Setter TargetName="bg" Property="BorderBrush" Value="#88ffffff" /></Trigger></ControlTemplate.Triggers></ControlTemplate></Button.Template></Button><TextBlock HorizontalAlignment="Center"><Run Text="Already have an account?" Foreground="#A1AEC3" /><Run Text=" Login" Foreground="#F2F4F8" FontWeight="Bold" Cursor="Hand" x:Name="BtnGoLogin" /></TextBlock></StackPanel><TextBlock x:Name="AuthMessage" Grid.Row="2" Text="" Foreground="#ff5555" FontSize="12" HorizontalAlignment="Center" Margin="0,15,0,0" TextWrapping="Wrap" TextAlignment="Center" /></Grid></Border></Grid></Grid></Border></Window>
"@

# Setup Background Media Loop Path
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
if (-not $scriptDir) { $scriptDir = $PWD.Path }
$bgPath = Join-Path $scriptDir "giphy.gif"

# Inject path into XAML
if (Test-Path $bgPath) {
    # Escape path for XML attribute
    $escapedBgPath = [System.Security.SecurityElement]::Escape($bgPath)
    $xaml = $xaml -replace 'BG_PATH_PLACEHOLDER', $escapedBgPath
} else {
    $xaml = $xaml -replace 'BG_PATH_PLACEHOLDER', ''
}

# Network adapter entry points, using the existing application styles.
[xml]$networkUi = $xaml
$ns = New-Object Xml.XmlNamespaceManager($networkUi.NameTable)
$ns.AddNamespace('w','http://schemas.microsoft.com/winfx/2006/xaml/presentation')
$ns.AddNamespace('x','http://schemas.microsoft.com/winfx/2006/xaml')
$view = $networkUi.SelectSingleNode('//*[@x:Name="ViewNetwork"]',$ns)
$panel = $view.SelectSingleNode('.//w:StackPanel',$ns)
$card = $networkUi.CreateDocumentFragment()
$card.InnerXml = @"
<Border xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" CornerRadius="16" Background="#191E2B" BorderBrush="#7451C8" BorderThickness="1" Padding="22" Margin="0,0,0,18">
 <StackPanel><TextBlock Text="NETWORK ADAPTER" Foreground="#B79AFF" FontSize="12" FontWeight="Bold"/><TextBlock Text="ปรับการ์ดแลนตามสไตล์คุณ" Foreground="White" FontSize="23" Margin="0,6,0,8"/><TextBlock Text="โหลดค่าอัตโนมัติ • RSS ตาม CPU • ปิด Power Saving • เว้นส่วน Tweaks" Foreground="#A1AEC3" TextWrapping="Wrap" Margin="0,0,0,16"/><UniformGrid Columns="2"><Button x:Name="BtnOpenAdapter" Content="เปิด Network Tweaker  ↗" Height="44" Margin="0,0,8,0" Style="{StaticResource SecondaryButton}"/><Button x:Name="BtnAdapterPreset" Content="โหลดค่าอัตโนมัติ  →" Height="44" Margin="8,0,0,0" Style="{StaticResource PremiumButton}"/></UniformGrid><TextBlock Text="เลือก Adapter แล้วกดโหลดค่าอัตโนมัติ ตรวจค่าและกด Apply All จากนั้นรีสตาร์ตเครื่อง" Foreground="#A1AEC3" FontSize="11" Margin="0,12,0,0" TextWrapping="Wrap"/></StackPanel>
</Border>
"@
[void]$panel.PrependChild($card)
$xaml = $networkUi.OuterXml
# Read XAML
$reader = (New-Object System.Xml.XmlNodeReader ([xml]$xaml))
$window = [Windows.Markup.XamlReader]::Load($reader)

# Define Arrays for easier looping
$views = @("ViewDashboard", "ViewCPU", "ViewInput", "ViewNetwork", "ViewFiveM", "ViewPower", "ViewTools", "ViewRestore")
$navButtons = @("BtnNavDashboard", "BtnNavCPU", "BtnNavInput", "BtnNavNetwork", "BtnNavFiveM", "BtnNavPower", "BtnNavTools", "BtnNavRestore")

# LOG FUNCTION
function Write-Log {
    param([string]$Message)
    # Log removed
}

# SYSTEM INFO GATHERING
function Update-SystemInfo {
    Write-Log "Gathering System Info..."
    try {
        $os = (Get-WmiObject Win32_OperatingSystem).Caption
        $window.FindName("SysOs").Text = "OS: $os"
        
        $cpu = (Get-WmiObject Win32_Processor).Name
        $window.FindName("SysCpu").Text = "CPU: $cpu"
        
        $ramObj = Get-WmiObject Win32_ComputerSystem
        $ramGb = [math]::Round($ramObj.TotalPhysicalMemory / 1GB, 1)
        $window.FindName("SysRam").Text = "RAM: $ramGb GB"
        
        # Simple HWID simulation or real UUID
        $uuid = (Get-WmiObject Win32_ComputerSystemProduct).UUID
        $window.FindName("SysHwid").Text = "HWID: $uuid"
        
        Write-Log "System Info updated."
    } catch {
        Write-Log "Failed to get system info."
    }
}

function Update-Status {
    Write-Log "Refreshing Status..."
    try {
        $win32prio = (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" -Name "Win32PrioritySeparation" -ErrorAction SilentlyContinue).Win32PrioritySeparation
        if ($null -ne $win32prio) {
            $hex = '0x{0:X2}' -f $win32prio
            $window.FindName("StatusPriority").Text = "Win32PrioritySeparation: $hex"
        }
        
        # Get active power plan output as a single string and extract the name in parentheses
        try {
            $activePlanOut = (& powercfg /GetActiveScheme 2>&1) -join "`n"
            if ($activePlanOut -match '\(([^\)]*)\)') {
                $planName = $matches[1]
                $window.FindName("StatusPlan").Text = "Power Plan: $planName"
            } else {
                # Fallback: try parsing the GUID line from powercfg /L
                $list = (& powercfg /L 2>&1) -join "`n"
                if ($list -match "\)\s*(.+)$") {
                    $window.FindName("StatusPlan").Text = "Power Plan: $($matches[1].Trim())"
                } else {
                    $window.FindName("StatusPlan").Text = "Power Plan: Unknown"
                }
            }
        } catch {
            $window.FindName("StatusPlan").Text = "Power Plan: Error"
        }
    } catch {}
}

# STARTUP
Write-Log "Redpro ready  |  Administrator"
Update-SystemInfo
Update-Status

# Function to switch views
function Switch-View {
    param([string]$targetViewName, [string]$targetButtonName)
    foreach ($viewName in $views) {
        $window.FindName($viewName).Visibility = 'Collapsed'
    }
    $window.FindName($targetViewName).Visibility = 'Visible'
    foreach ($btnName in $navButtons) {
        $window.FindName($btnName).Style = $window.Resources["MenuButton"]
    }
    $window.FindName($targetButtonName).Style = $window.Resources["ActiveMenuButton"]
    Write-Log "Navigated to $targetViewName"
}

# NAVIGATION
$window.FindName("BtnNavDashboard").Add_Click({ Switch-View "ViewDashboard" "BtnNavDashboard" })
$window.FindName("BtnNavCPU").Add_Click({ Switch-View "ViewCPU" "BtnNavCPU" })
$window.FindName("BtnNavInput").Add_Click({ Switch-View "ViewInput" "BtnNavInput" })
$window.FindName("BtnNavNetwork").Add_Click({ Switch-View "ViewNetwork" "BtnNavNetwork" })

$window.FindName("BtnNavFiveM").Add_Click({ Switch-View "ViewFiveM" "BtnNavFiveM" })

function Set-FiveMMtu1080 {
    param([Parameter(Mandatory=$true)][string]$ConfigPath)
    $folder = Split-Path -Parent $ConfigPath
    [IO.Directory]::CreateDirectory($folder) | Out-Null
    $encoding = New-Object Text.UTF8Encoding($false)
    $content = ''
    $exists = [IO.File]::Exists($ConfigPath)
    if ($exists) {
        $reader = New-Object IO.StreamReader($ConfigPath, $encoding, $true)
        try { $content = $reader.ReadToEnd(); $encoding = $reader.CurrentEncoding } finally { $reader.Dispose() }
    }
    $newline = if ($content.Contains("`r`n")) { "`r`n" } elseif ($content.Contains("`n")) { "`n" } else { "`r`n" }
    $pattern = '(?im)^(?<prefix>[\t ]*(?:(?:set|seta|setr|sets)[\t ]+)?"?net_maxMtu"?[\t ]+)(?:"[^"\r\n]*"|[^\s\r\n]+)(?<tail>[^\r\n]*)(?=\r?$)'
    if ([regex]::IsMatch($content, $pattern)) {
        $updated = [regex]::Replace($content, $pattern, '${prefix}1080${tail}')
    } else {
        $separator = if ($content.Length -gt 0 -and -not $content.EndsWith("`n")) { $newline } else { '' }
        $updated = $content + $separator + 'net_maxMtu 1080' + $newline
    }
    if ($updated -ceq $content) { return 'ตั้งค่าเป็น 1080 อยู่แล้ว' }
    $suffix = [Guid]::NewGuid().ToString('N')
    $temporary = Join-Path $folder ('.fivem-' + $suffix + '.tmp')
    $backup = $ConfigPath + '.' + $suffix + '.bak'
    try {
        [IO.File]::WriteAllText($temporary, $updated, $encoding)
        if ($exists) { [IO.File]::Replace($temporary, $ConfigPath, $backup) }
        else { [IO.File]::Move($temporary, $ConfigPath) }
    } finally {
        if ([IO.File]::Exists($temporary)) { [IO.File]::Delete($temporary) }
    }
    if ($exists) { return "บันทึก MTU 1080 แล้ว เปิด FiveM ใหม่เพื่อใช้ค่า`nไฟล์สำรอง: $backup" }
    return 'สร้าง fivem.cfg และบันทึก MTU 1080 แล้ว เปิด FiveM ใหม่เพื่อใช้ค่า'
}

$window.FindName('BtnFiveM1080').Add_Click({
    $button = $window.FindName('BtnFiveM1080')
    $result = $window.FindName('FiveMResult')
    $button.IsEnabled = $false
    try {
        $roaming = [Environment]::GetFolderPath('ApplicationData')
        if ([string]::IsNullOrWhiteSpace($roaming)) { throw 'ไม่พบโฟลเดอร์ AppData ของผู้ใช้' }
        $cfg = Join-Path $roaming 'CitizenFX\fivem.cfg'
        $result.Text = Set-FiveMMtu1080 -ConfigPath $cfg
        $result.Foreground = '#C4B5FD'
    } catch {
        $result.Text = 'บันทึกไม่สำเร็จ: ' + $_.Exception.Message
        $result.Foreground = '#FDA4AF'
    } finally { $button.IsEnabled = $true }
})
$window.FindName("BtnNavPower").Add_Click({ Switch-View "ViewPower" "BtnNavPower" })
$window.FindName("BtnNavTools").Add_Click({ Switch-View "ViewTools" "BtnNavTools" })
$window.FindName("BtnNavRestore").Add_Click({ Switch-View "ViewRestore" "BtnNavRestore" })

# RUN-TWEAK HELPER FUNCTION
function Run-Tweak {
    param(
        [System.Windows.Controls.Button]$Btn,
        [string]$LoadingText,
        [scriptblock]$Action
    )
    
    $txt = $Btn.Content
    if ($txt -is [System.Windows.Controls.StackPanel]) {
        $txtBlock = $txt.Children | Where-Object { $_ -is [System.Windows.Controls.TextBlock] -and $_.Text -ne "" -and $_.FontFamily -notmatch "Segoe MDL2 Assets" } | Select-Object -First 1
        if ($txtBlock) {
            $oldText = $txtBlock.Text
            $txtBlock.Text = $LoadingText
        }
    } elseif ($txt -is [System.Windows.Controls.TextBlock]) {
        $oldText = $txt.Text
        $txt.Text = $LoadingText
    } else {
        $oldText = $Btn.Content
        $Btn.Content = $LoadingText
    }
    
    $Btn.IsEnabled = $false
    
    # Force UI update
    $frame = New-Object System.Windows.Threading.DispatcherFrame
    [System.Windows.Threading.Dispatcher]::CurrentDispatcher.BeginInvoke("Background", [System.Action] { $frame.Continue = $false }) | Out-Null
    [System.Windows.Threading.Dispatcher]::PushFrame($frame)

    try {
        & $Action
    } catch {
        Write-Log $_.Exception.Message
    }

    if ($txtBlock) {
        $txtBlock.Text = "SUCCESS!"
    } elseif ($txt -is [System.Windows.Controls.TextBlock]) {
        $txt.Text = "SUCCESS!"
    } else {
        $Btn.Content = "SUCCESS!"
    }
    
    # Re-force UI update to show success for 1 second
    $frame2 = New-Object System.Windows.Threading.DispatcherFrame
    [System.Windows.Threading.Dispatcher]::CurrentDispatcher.BeginInvoke("Background", [System.Action] { $frame2.Continue = $false }) | Out-Null
    [System.Windows.Threading.Dispatcher]::PushFrame($frame2)
    
    Start-Sleep -Seconds 1
    
    if ($txtBlock) {
        $txtBlock.Text = $oldText
    } elseif ($txt -is [System.Windows.Controls.TextBlock]) {
        $txt.Text = $oldText
    } else {
        $Btn.Content = $oldText
    }
    $Btn.IsEnabled = $true
}

$dekDir = Join-Path $scriptDir "Dek_Tools"

# DASHBOARD ACTIONS
$window.FindName("BtnTutorialDashboard").Add_Click({
    Start-Process "https://youtu.be/iqlivQ2cZFw?si=6tpBzXwkPue0H3X0"
})
$window.FindName("BtnApplyRec").Add_Click({
    Run-Tweak -Btn $window.FindName("BtnApplyRec") -LoadingText "APPLYING TWEAKS..." -Action {
        Start-Process -FilePath "reg.exe" -ArgumentList "import `"$dekDir\2.Tweaker\1.Reg.reg`""
        Start-Process -FilePath "$dekDir\2.Tweaker\5.Background_Startup_Apps.bat"
        Start-Process -FilePath "$dekDir\2.Tweaker\7.Disable_Unnecessary_Services.bat"
        Start-Process -FilePath "$dekDir\2.Tweaker\8.Focus_FiveM.bat"
    }
})
# CPU ACTIONS
$window.FindName("BtnCpu2A").Add_Click({
    Run-Tweak -Btn $window.FindName("BtnCpu2A") -LoadingText "CLEANING UP..." -Action {
        Start-Process -FilePath "$dekDir\2.Tweaker\9.Process_Killer.bat"
        Update-Status
    }
})
function Set-Win32Prio {
    param([int]$val, [string]$hex)
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" -Name "Win32PrioritySeparation" -Value $val -Type DWord -Force
    Update-Status
}
$window.FindName("BtnCpu26").Add_Click({ Run-Tweak -Btn $window.FindName("BtnCpu26") -LoadingText "APPLYING..." -Action { Set-Win32Prio 38 "0x26" } })
$window.FindName("BtnCpu28").Add_Click({ Run-Tweak -Btn $window.FindName("BtnCpu28") -LoadingText "APPLYING..." -Action { Set-Win32Prio 40 "0x28" } })
$window.FindName("BtnCpu16").Add_Click({ Run-Tweak -Btn $window.FindName("BtnCpu16") -LoadingText "APPLYING..." -Action { Set-Win32Prio 22 "0x16" } })
$window.FindName("BtnCpu18").Add_Click({ Run-Tweak -Btn $window.FindName("BtnCpu18") -LoadingText "APPLYING..." -Action { Set-Win32Prio 24 "0x18" } })
$window.FindName("BtnCpuDef").Add_Click({ Run-Tweak -Btn $window.FindName("BtnCpuDef") -LoadingText "APPLYING..." -Action { Set-Win32Prio 2 "0x02 (Default)" } })

$window.FindName("BtnUnpark").Add_Click({
    Run-Tweak -Btn $window.FindName("BtnUnpark") -LoadingText "UNPARKING..." -Action {
        powercfg -setacvalueindex scheme_current sub_processor CPMINCORES 100
        powercfg -setactive scheme_current
    }
})
$window.FindName("BtnPark").Add_Click({
    Run-Tweak -Btn $window.FindName("BtnPark") -LoadingText "RESTORING..." -Action {
        powercfg -setacvalueindex scheme_current sub_processor CPMINCORES 5
        powercfg -setactive scheme_current
    }
})

# INPUT ACTIONS
$window.FindName("BtnInputMouse").Add_Click({
    Run-Tweak -Btn $window.FindName("BtnInputMouse") -LoadingText "OPTIMIZING INPUT..." -Action {
        Start-Process -FilePath "$dekDir\2.Tweaker\6.Mouse_Keyboard.bat"
    }
})
$window.FindName("BtnInputRestore").Add_Click({
    Run-Tweak -Btn $window.FindName("BtnInputRestore") -LoadingText "RESTORING..." -Action {
        Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseSpeed" -Value "1" -Force
        Set-ItemProperty -Path "HKCU:\Control Panel\Keyboard" -Name "KeyboardDelay" -Value "1" -Force
    }
})

function Open-RedproNetworkAdapter {
    param([switch]$Preset)
    $path = Join-Path $scriptDir 'Dek_Tools\Network_Tweaker.ps1'
    if (-not (Test-Path -LiteralPath $path)) {
        [Windows.MessageBox]::Show("ไม่พบไฟล์ $path", 'Network Adapter') | Out-Null
        return
    }
    $arguments = '-NoProfile -STA -ExecutionPolicy Bypass -File "' + $path + '"'
    if ($Preset) { $arguments += ' -RedproPreset' }
    try { Start-Process powershell.exe -ArgumentList $arguments -WindowStyle Hidden -ErrorAction Stop }
    catch { [Windows.MessageBox]::Show($_.Exception.Message, 'Network Adapter') | Out-Null }
}
$window.FindName('BtnOpenAdapter').Add_Click({ Open-RedproNetworkAdapter })
$window.FindName('BtnAdapterPreset').Add_Click({ Open-RedproNetworkAdapter -Preset })
# NETWORK ACTIONS
$window.FindName("BtnNetTweak").Add_Click({
    Run-Tweak -Btn $window.FindName("BtnNetTweak") -LoadingText "OPTIMIZING NETWORK..." -Action {
        Start-Process -FilePath "$dekDir\2.Tweaker\3. Network Engine Stack.bat"
    }
})
$window.FindName("BtnNetFlush").Add_Click({
    Run-Tweak -Btn $window.FindName("BtnNetFlush") -LoadingText "FLUSHING..." -Action {
        ipconfig /flushdns | Out-Null
        netsh winsock reset | Out-Null
    }
})
$window.FindName("BtnNetRestore").Add_Click({
    Run-Tweak -Btn $window.FindName("BtnNetRestore") -LoadingText "RESTORING..." -Action {
        netsh int tcp set global autotuninglevel=normal | Out-Null
        netsh int tcp set global chimney=default | Out-Null
        netsh int tcp set global dca=default | Out-Null
        netsh int tcp set global netdma=default | Out-Null
    }
})

# POWER / TIMER ACTIONS
$window.FindName("BtnPowerImport").Add_Click({
    Run-Tweak -Btn $window.FindName("BtnPowerImport") -LoadingText "APPLYING ULTIMATE POWER..." -Action {
        Start-Process -FilePath "powershell.exe" -ArgumentList "-ExecutionPolicy Bypass -File `"$dekDir\2.Tweaker\2.Optimization Toolkit.ps1`""
        Update-Status
    }
})
$window.FindName("BtnTimerEnable").Add_Click({
    Run-Tweak -Btn $window.FindName("BtnTimerEnable") -LoadingText "ENABLING TIMER..." -Action {
        Start-Process -FilePath "$dekDir\2.Tweaker\4.Timer Resolution Service.bat"
        Update-Status
    }
})
$window.FindName("BtnTimerDisable").Add_Click({
    Run-Tweak -Btn $window.FindName("BtnTimerDisable") -LoadingText "DISABLING TIMER..." -Action {
        sc.exe stop "Set Timer Resolution Service" | Out-Null
        sc.exe delete "Set Timer Resolution Service" | Out-Null
        Update-Status
    }
})

# TOOLS ACTIONS
$window.FindName("BtnMsiUtil").Add_Click({
    Run-Tweak -Btn $window.FindName("BtnMsiUtil") -LoadingText "LAUNCHING..." -Action {
        Start-Process -FilePath "$dekDir\1.App\2.MSI_util_v3.exe"
    }
})
$window.FindName("BtnDeviceCleanup").Add_Click({
    Run-Tweak -Btn $window.FindName("BtnDeviceCleanup") -LoadingText "LAUNCHING..." -Action {
        Start-Process -FilePath "$dekDir\1.App\3.Device Cleanup.exe"
    }
})
$window.FindName("BtnMemCleaner").Add_Click({
    Run-Tweak -Btn $window.FindName("BtnMemCleaner") -LoadingText "LAUNCHING..." -Action {
        Start-Process -FilePath "$dekDir\1.App\Memory Cleaner.exe"
    }
})
$window.FindName("BtnWinUtil").Add_Click({
    Run-Tweak -Btn $window.FindName("BtnWinUtil") -LoadingText "LAUNCHING..." -Action {
        Start-Process -FilePath "powershell.exe" -ArgumentList "-ExecutionPolicy Bypass -File `"$dekDir\1.App\1.winutil.ps1`""
    }
})

# RESTORE ACTIONS
$window.FindName("BtnRestoreAll").Add_Click({
    Run-Tweak -Btn $window.FindName("BtnRestoreAll") -LoadingText "RESTORING SETTINGS..." -Action {
        # Basic restore
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" -Name "Win32PrioritySeparation" -Value 2 -Type DWord -Force
        powercfg -setacvalueindex scheme_current sub_processor CPMINCORES 5
        powercfg -setactive scheme_current
        Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseSpeed" -Value "1" -Force
        netsh int tcp set global autotuninglevel=normal | Out-Null
        bcdedit /deletevalue disabledynamictick | Out-Null
        Update-Status
    }
})
$window.FindName("BtnRestorePoint").Add_Click({
    Run-Tweak -Btn $window.FindName("BtnRestorePoint") -LoadingText "CREATING BACKUP..." -Action {
        try {
            Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue
            Checkpoint-Computer -Description "Redpro Backup" -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop
        } catch { }
    }
})

# Load Images if they exist
if ($PSScriptRoot) {
    $scriptDir = $PSScriptRoot
} else {
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
    if (-not $scriptDir) { $scriptDir = $PWD.Path }
}
$avatarPath = Join-Path $scriptDir "IMG_6322.jpg"
if (Test-Path $avatarPath) {
    try {
        $img = New-Object System.Windows.Media.Imaging.BitmapImage(New-Object Uri($avatarPath))
        $icoPath = Join-Path $scriptDir "IMG_6322.jpg"
        if (Test-Path $icoPath) {
            $window.Icon = New-Object System.Windows.Media.Imaging.BitmapImage(New-Object Uri($icoPath))
        }
        $brush = New-Object System.Windows.Media.ImageBrush($img)
        $brush.Stretch = "UniformToFill"
        $window.FindName("ProfileImage").Fill = $brush
        $window.FindName("AuthProfileImage").Fill = $brush
    } catch {}
}

$bannerPath = Join-Path $scriptDir "1.jpg"
if (Test-Path $bannerPath) {
    try {
        $img = New-Object System.Windows.Media.Imaging.BitmapImage(New-Object Uri($bannerPath))
        $brush = New-Object System.Windows.Media.ImageBrush($img)
        $brush.Stretch = "UniformToFill"
        $brush.AlignmentY = "Top"
        # Crop the top 20% of the image to skip the head, and use the remaining 80% to fill
        $brush.Viewbox = New-Object System.Windows.Rect(0, 0.20, 1, 0.80)
        $window.FindName("BannerImage").Background = $brush
    } catch {}
}

$sidebarPath = Join-Path $scriptDir "ddd.jpg"
if (Test-Path $sidebarPath) {
    try {
        $img = New-Object System.Windows.Media.Imaging.BitmapImage(New-Object Uri($sidebarPath))
        $brush = New-Object System.Windows.Media.ImageBrush($img)
        $brush.Stretch = "UniformToFill"
        $brush.AlignmentY = "Top"
        $window.FindName("SidebarImage").Background = $brush
        $window.FindName("SidebarPlaceholderText").Visibility = "Collapsed"
    } catch {}
}

# Window Controls
$window.FindName("BtnMinimize").Add_Click({ $window.WindowState = 'Minimized' })
$window.FindName("BtnClose").Add_Click({ $window.Close() })
$window.FindName("TitleBar").Add_MouseLeftButtonDown({ $window.DragMove() })

# Animation: Slow Fade In
$window.Opacity = 0
$window.Add_Loaded({
    $anim = New-Object System.Windows.Media.Animation.DoubleAnimation
    $anim.From = 0.0
    $anim.To = 1.0
    $anim.Duration = [System.Windows.Duration]::new([timespan]::FromSeconds(1.5))
    $ease = New-Object System.Windows.Media.Animation.CubicEase
    $ease.EasingMode = [System.Windows.Media.Animation.EasingMode]::EaseOut
    $anim.EasingFunction = $ease
    $window.BeginAnimation([System.Windows.Window]::OpacityProperty, $anim)
})

# Background Music
$bgmPath = Join-Path $scriptDir "bgm.mp3"

if (Test-Path $bgmPath) {
    $global:bgmPlayer = New-Object System.Windows.Media.MediaPlayer
    $global:bgmPlayer.Open([uri]$bgmPath)
    $global:bgmPlayer.Volume = 0.3

    $global:bgmPlayer.Play()
}


$global:isMuted = $false
$global:lastMuteClickTime = 0
$window.FindName("BtnMuteToggle").Add_Click({
    $now = [Environment]::TickCount
    if (($now - $global:lastMuteClickTime) -lt 500 -and $global:lastMuteClickTime -ne 0) {
        # Double Click: Mute / Unmute
        if ($global:bgmPlayer) {
            if ($global:isMuted) {
                $global:bgmPlayer.Play()
                $global:isMuted = $false
                $window.FindName("BtnMuteToggle").Content = [char]0xE767
            } else {
                $global:bgmPlayer.Pause()
                $global:isMuted = $true
                $window.FindName("BtnMuteToggle").Content = [char]0xE74F
            }
        }
        $global:lastMuteClickTime = 0
    } else {
        # Single Click: Toggle Slider Visibility
        $slider = $window.FindName("VolumeSlider")
        if ($slider.Visibility -eq "Visible") {
            $slider.Visibility = "Collapsed"
        } else {
            $slider.Visibility = "Visible"
        }
        $global:lastMuteClickTime = $now
    }
})
$window.FindName("VolumeSlider").Add_ValueChanged({
    param($sender, $e)
    if ($global:bgmPlayer) {
        $global:bgmPlayer.Volume = $sender.Value
    }
})

# AUTHENTICATION LOGIC
$appDataDir = Join-Path $env:APPDATA "AugustKodomo"
if (-not (Test-Path $appDataDir)) { New-Item -ItemType Directory -Force -Path $appDataDir | Out-Null }
$licenseFile = Join-Path $appDataDir "license.dat"

function Get-HWID {
    try {
        $uuid = (Get-WmiObject Win32_ComputerSystemProduct).UUID
        return $uuid
    } catch {
        return "UNKNOWN-HWID"
    }
}
$hwid = Get-HWID
$window.FindName("TxtHWID").Text = $hwid

function Hash-String ($string) {
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($string)
    $sha256 = [System.Security.Cryptography.SHA256]::Create()
    $hash = $sha256.ComputeHash($bytes)
    return [BitConverter]::ToString($hash).Replace("-","")
}

$authLoginView = $window.FindName("AuthLoginView")
$authRegisterView = $window.FindName("AuthRegisterView")
$authMessage = $window.FindName("AuthMessage")
$authContainer = $window.FindName("AuthContainer")
$mainAppContainer = $window.FindName("MainAppContainer")

$authLoginView.Visibility = "Visible"
$authRegisterView.Visibility = "Collapsed"
if (Test-Path $licenseFile) {
    try {
        $savedKey = Get-Content -Path $licenseFile -Raw
        $savedKey = $savedKey.Trim()
        $window.FindName("TxtLoginPassword").Password = $savedKey
    } catch {}
}

# Toggle views handlers removed since Register view is disabled

$window.FindName("BtnRegister").Add_Click({
    $pass1 = if ($window.FindName("TxtRegPasswordVisible").Visibility -eq "Visible") { $window.FindName("TxtRegPasswordVisible").Text } else { $window.FindName("TxtRegPassword").Password }
    $pass2 = if ($window.FindName("TxtRegPasswordConfirmVisible").Visibility -eq "Visible") { $window.FindName("TxtRegPasswordConfirmVisible").Text } else { $window.FindName("TxtRegPasswordConfirm").Password }
    if ($pass1.Length -lt 4) {
        $authMessage.Foreground = "#ff4444"
        $authMessage.Text = "Password must be at least 4 characters."
        return
    }
    if ($pass1 -ne $pass2) {
        $authMessage.Foreground = "#ff4444"
        $authMessage.Text = "Passwords do not match."
        return
    }
    $hashed = Hash-String "${hwid}_${pass1}"
    Set-Content -Path $licenseFile -Value $hashed -Force
    $authMessage.Foreground = "#ffffff"
    $authMessage.Text = "Account created. You can now Login."
    $authLoginView.Visibility = "Visible"
    $authRegisterView.Visibility = "Collapsed"
})

$window.FindName("BtnToggleLoginPass").Add_Checked({
    $window.FindName("TxtLoginPasswordVisible").Text = $window.FindName("TxtLoginPassword").Password
    $window.FindName("TxtLoginPasswordVisible").Visibility = "Visible"
    $window.FindName("TxtLoginPassword").Visibility = "Collapsed"
})
$window.FindName("BtnToggleLoginPass").Add_Unchecked({
    $window.FindName("TxtLoginPassword").Password = $window.FindName("TxtLoginPasswordVisible").Text
    $window.FindName("TxtLoginPassword").Visibility = "Visible"
    $window.FindName("TxtLoginPasswordVisible").Visibility = "Collapsed"
})

$window.FindName("BtnToggleRegPass").Add_Checked({
    $window.FindName("TxtRegPasswordVisible").Text = $window.FindName("TxtRegPassword").Password
    $window.FindName("TxtRegPasswordVisible").Visibility = "Visible"
    $window.FindName("TxtRegPassword").Visibility = "Collapsed"
})
$window.FindName("BtnToggleRegPass").Add_Unchecked({
    $window.FindName("TxtRegPassword").Password = $window.FindName("TxtRegPasswordVisible").Text
    $window.FindName("TxtRegPassword").Visibility = "Visible"
    $window.FindName("TxtRegPasswordVisible").Visibility = "Collapsed"
})

$window.FindName("BtnToggleRegPassConfirm").Add_Checked({
    $window.FindName("TxtRegPasswordConfirmVisible").Text = $window.FindName("TxtRegPasswordConfirm").Password
    $window.FindName("TxtRegPasswordConfirmVisible").Visibility = "Visible"
    $window.FindName("TxtRegPasswordConfirm").Visibility = "Collapsed"
})
$window.FindName("BtnToggleRegPassConfirm").Add_Unchecked({
    $window.FindName("TxtRegPasswordConfirm").Password = $window.FindName("TxtRegPasswordConfirmVisible").Text
    $window.FindName("TxtRegPasswordConfirm").Visibility = "Visible"
    $window.FindName("TxtRegPasswordConfirmVisible").Visibility = "Collapsed"
})

$window.FindName("BtnLogin").Add_Click({
    $authMessage.Foreground = "#ffffff"
    $authMessage.Text = "Checking license..."
    
    # Custom Auth - Cloudflare Worker
    $authUrl = "https://redpro-auth.reallixarawin.workers.dev"
    
    $key = if ($window.FindName("TxtLoginPasswordVisible").Visibility -eq "Visible") { $window.FindName("TxtLoginPasswordVisible").Text } else { $window.FindName("TxtLoginPassword").Password }
    
    if (-not $key) {
        $authMessage.Foreground = "#ff4444"
        $authMessage.Text = "Please enter your license key."
        return
    }
    $key = $key.Trim()
    
    try {
        $escapedKey = [uri]::EscapeDataString($key)
        $escapedHwid = [uri]::EscapeDataString($hwid)
        $verifyUri = "${authUrl}/verify?key=${escapedKey}&hwid=${escapedHwid}"
        $loginResp = Invoke-RestMethod -Uri $verifyUri -Method Get -TimeoutSec 10
        
        if ($loginResp.success -eq $true) {
            # Save the valid key locally for auto-fill next time
            Set-Content -Path $licenseFile -Value $key -Force
            
            # Login successful
            $window.Resources["WindowControlForeground"] = [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.ColorConverter]::ConvertFromString("#ffffff"))
            $window.Resources["TitleDotColor"] = [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.ColorConverter]::ConvertFromString("#ffffff"))
            $authContainer.Visibility = "Collapsed"
            $mainAppContainer.Visibility = "Visible"
            $authMessage.Text = ""
        } else {
            $authMessage.Foreground = "#ff4444"
            $authMessage.Text = $loginResp.message
        }
    } catch {
        $authMessage.Foreground = "#ff4444"
        $authMessage.Text = "Connection error: $_"
    }
})

# Show Window
$window.ShowDialog() | Out-Null

