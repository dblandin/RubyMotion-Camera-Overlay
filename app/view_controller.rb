class ViewController < UIViewController
  attr_accessor :image_view, :take_picture_button, :image_picker

  def viewDidLoad
    super

    view.backgroundColor = UIColor.whiteColor

    self.image_view = UIImageView.alloc.initWithFrame(view.bounds)

    self.take_picture_button = UIButton.buttonWithType(UIButtonTypeRoundedRect).tap do |button|
      button.frame = CGRectMake(0, 0, 100, 40)
      button.center = CGPointMake(view.size.width / 2, view.size.height / 2)
      button.setTitle('Take Picture', forState: UIControlStateNormal)
      button.addTarget(self, action: 'take_picture:', forControlEvents: UIControlEventTouchUpInside)
    end

    [image_view, take_picture_button].each { |v| view.addSubview(v) }
  end

  def shouldAutorotateToInterfaceOrientation(interfaceOrientation)
    interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown
  end

  def take_picture(sender)
    unless UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceTypeCamera)
      alert = UIAlertView.alloc.initWithTitle('Error',
                                              message: 'Camera Unavailable',
                                             delegate: self,
                                    cancelButtonTitle: 'Cancel',
                                    otherButtonTitles: nil)
      alert.show

      return
    end

    unless image_picker
      self.image_picker = UIImagePickerController.alloc.init.tap do |picker|
        picker.delegate = self
        picker.sourceType = UIImagePickerControllerSourceTypeCamera
        picker.mediaTypes = UIImagePickerController.availableMediaTypesForSourceType(UIImagePickerControllerSourceTypeCamera)
        picker.allowsEditing = true
        picker.showsCameraControls = false
        picker.cameraOverlayView = overlay_for_image_picker(image_picker)
      end
    end

    presentViewController(image_picker, animated: true, completion: nil)
  end

  def imagePickerController(picker, didFinishPickingMediaWithInfo: info)
    image = info[UIImagePickerControllerOriginalImage]
    UIImageWriteToSavedPhotosAlbum(image, nil, nil , nil)

    image_view.image = image
    image_view.contentMode = UIViewContentModeScaleAspectFill

    dismissViewControllerAnimated(true, completion: nil)
  end

  def imagePickerControllerDidCancel(picker)
    dismissViewControllerAnimated(true, completion: nil)
  end

  def overlay_for_image_picker(image_picker)
    UIView.alloc.initWithFrame(CGRectMake(0, 0, 280, 480)).tap do |overlay|
      overlay.backgroundColor = UIColor.clearColor

      UIButton.alloc.initWithFrame(CGRectMake(10, 10, 120, 44)).tap do |button|
        button.backgroundColor = UIColor.colorWithRed(0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        button.setTitle('Flash Auto', forState: UIControlStateNormal)
        button.setTitleColor(UIColor.whiteColor, forState: UIControlStateNormal)
        button.addTarget(self, action: 'toggle_flash:', forControlEvents: UIControlEventTouchUpInside)
        overlay.addSubview(button)
      end

      UIButton.alloc.initWithFrame(CGRectMake(190, 10, 120, 44)).tap do |button|
        button.backgroundColor = UIColor.colorWithRed(0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        button.setTitle('Rear Camera', forState: UIControlStateNormal)
        button.setTitleColor(UIColor.whiteColor, forState: UIControlStateNormal)
        button.addTarget(self, action: 'toggle_camera:', forControlEvents: UIControlEventTouchUpInside)
        overlay.addSubview(button)
      end

      UIButton.alloc.initWithFrame(CGRectMake(100, 432, 120, 44)).tap do |button|
        button.backgroundColor = UIColor.colorWithRed(0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        button.setTitle('Click!', forState: UIControlStateNormal)
        button.setTitleColor(UIColor.whiteColor, forState: UIControlStateNormal)
        button.addTarget(image_picker, action: 'takePicture', forControlEvents: UIControlEventTouchUpInside)
        overlay.addSubview(button)
      end
    end
  end

  def toggle_flash(sender)
    if flash_mode_off?
      image_picker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOn
      sender.setTitle('Flash On', forState: UIControlStateNormal)
    else
      image_picker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff
      sender.setTitle('Flash Off', forState: UIControlStateNormal)
    end
    end

  def toggle_camera(sender)
    if using_rear_camera?
      image_picker.cameraDevice = UIImagePickerControllerCameraDeviceFront
      sender.setTitle('Front Camera', forState: UIControlStateNormal)
    else
      image_picker.cameraDevice = UIImagePickerControllerCameraDeviceRear
      sender.setTitle('Rear Camera', forState: UIControlStateNormal)
    end
  end

  def using_rear_camera?
    image_picker.cameraDevice == UIImagePickerControllerCameraDeviceRear
  end

  def flash_mode_off?
    image_picker.cameraFlashMode == UIImagePickerControllerCameraFlashModeOff
  end
end
