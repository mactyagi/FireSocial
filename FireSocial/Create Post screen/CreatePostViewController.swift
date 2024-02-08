//
//  CreatePostViewController.swift
//  FireSocial
//
//  Created by Manu on 07/02/24.
//

import UIKit
import PhotosUI
import FirebaseStorage
import FirebaseFirestore

class CreatePostViewController: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var addPhotoButton: UIButton!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var textView: UITextView!
    
    //MARK: - Properties
    let defaultText = "Share your thoughts ..."
    var loadingOverlay: LoadingOverlay?
    var picker: PHPickerViewController?
    var arrayOfImages = [UIImage](){
        didSet{
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    
    //MARK: - Life cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    
    //MARK: - IBActions
    @IBAction func postButtonPressed(_ sender: UIButton) {
        if arrayOfImages.isEmpty{
            showMessagePrompt(title: "Error", message: "Post should have atleast one photo.")
            return
        }
        guard let userId = UserDefaults.standard.string(forKey: Constants.kUSERID) else { return }
        DispatchQueue.global().async {
            DispatchQueue.main.async {
                self.showLoader()
            }
            let urls = self.uploadPhotosToStorage()
            print(urls)
            
            DispatchQueue.main.async {
                var text = ""
                if self.textView.text != self.defaultText{
                    text = self.textView.text
                }
                let UUID = UUID()
                let post = Post(id: "\(UUID)", imageURLs: urls, description: text, userId: userId, creationDate: Date())
                self.uploadPostToFireStore(post: post)
                self.hideLoader()
            }
        }
    }
    
    
    @IBAction func addPhotoButtonPressed(_ sender: UIButton) {
        showImagePicker()
    }
    
    
    //MARK: - functions
    
    func setupOverLay(){
        loadingOverlay = LoadingOverlay(frame: view.bounds)
        loadingOverlay?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(loadingOverlay!)
        loadingOverlay?.isHidden = true
    }
    
    func showLoader() {
        loadingOverlay?.isHidden = false
        loadingOverlay?.startAnimating()
        view.alpha = 0.5
    }
    
    func hideLoader() {
        loadingOverlay?.isHidden = true
        view.alpha = 1.0
    }
    
    func uploadPhotosToStorage() -> [String]{
        let dispatchGroup = DispatchGroup()
        var urls = [String]()
        for image in arrayOfImages{
            if let datum = image.jpegData(compressionQuality: 0.4){
                dispatchGroup.enter()
                let UUID = UUID()
                let ref = Storage.storage().reference().child("postImages/\(UUID)")
                let _ = ref.putData(datum) { storage, error in
                    if let error = error{
                        print(error.localizedDescription)
                        dispatchGroup.leave()
                    }else{
                        ref.downloadURL { url, error in
                            if let error{
                                print(error)
                            }
                            if let url{
                                urls.append(url.absoluteString)
                                print(url.absoluteString)
                            }
                            dispatchGroup.leave()
                        }
                    }
                }
            }
        }
        dispatchGroup.wait()
        return urls
    }
    
    func uploadPostToFireStore(post: Post){
        let db = Firestore.firestore()
        
        do{
            try db.collection("Post").document(post.id).setData(from: post)
            self.showMessagePrompt(title: "Posted", message: "Your post is Live.")
            self.arrayOfImages = []
            self.textView.text = self.defaultText
        }catch let error{
            print(error)
            self.showMessagePrompt(title: "Error", message: error.localizedDescription)
        }
    }
    
    func setupCollectionView(){
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "CreatePostCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CreatePostCollectionViewCell")
    }
    
    private func showImagePicker() {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 10
        configuration.filter = .images
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    
    func setupViews(){
        setupOverLay()
        setupCollectionView()
        setupTextView()
        postButton.layer.cornerRadius = 10
        addPhotoButton.layer.cornerRadius = 10
    }
    
    func setupTextView(){
        textView.text = defaultText
        textView.textColor = .gray
        textView.delegate = self
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        toolbar.setItems([doneButton], animated: false)
        textView.inputAccessoryView = toolbar
    }
    
    @objc func doneButtonTapped() {
        textView.resignFirstResponder()
        if textView.text == "" {
            textView.text = defaultText
            textView.textColor = .gray
        }
    }
}

extension CreatePostViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        arrayOfImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CreatePostCollectionViewCell", for: indexPath) as! CreatePostCollectionViewCell
        cell.configureCell(image: arrayOfImages[indexPath.row], indexPath: indexPath)
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cellWidth = (collectionView.frame.width - 20) / 3
        
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    
}


extension CreatePostViewController: CreatePostCollectionViewCellDelegate{
    func createPostCollectionViewCell(_ cell: CreatePostCollectionViewCell, didDeleteButtonPressedAt indexpath: IndexPath) {
        arrayOfImages.remove(at: indexpath.row)
    }
    
    
}


extension CreatePostViewController: PHPickerViewControllerDelegate{
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true, completion: nil)
        
        for result in results {
            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                    if let error = error {
                        print("Error loading image: \(error.localizedDescription)")
                        return
                    }
                    if let image = image as? UIImage {
                        // Handle the selected image
                        self?.arrayOfImages.append(image)
                    }
                }
            }
        }
    }
}


extension CreatePostViewController: UITextViewDelegate{
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == defaultText{
            textView.text = ""
            textView.textColor = .label
        }
    }
}
