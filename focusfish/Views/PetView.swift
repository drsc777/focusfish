import SwiftUI

struct PetView: View {
    @ObservedObject var petViewModel: PetViewModel
    
    var body: some View {
        PetStatusView(petViewModel: petViewModel)
    }
}

struct PetView_Previews: PreviewProvider {
    static var previews: some View {
        PetView(petViewModel: PetViewModel())
    }
} 