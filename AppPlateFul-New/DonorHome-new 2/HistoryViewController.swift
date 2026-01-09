import UIKit

class HistoryViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var histories: [DonationHistory] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 150

        setupFakeData()
    }
    
    var selectedHistory: DonationHistory?
    

    func setupFakeData() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"

        histories = [
            DonationHistory(
                imageName: "restaurant1",
                restaurantName: "Burger House",
                currentStatus: "Donated",
                finalStatus: "Completed",
                date: formatter.date(from: "2026-01-10 14:30")!,
                itemsWithQuantity: "Chicken Shawarma (x14)",
                pickupDate: formatter.date(from: "2026-01-11 10:00")!,
                house: "189",
                road: "3774",
                block: "332",
                area: "Arad",
                mobileNumber: "+97333334444"
            ),
            DonationHistory(
                imageName: "restaurant2",
                restaurantName: "Pizza Corner",
                currentStatus: "Pending",
                finalStatus: "Canceled",
                date: formatter.date(from: "2026-01-08 18:45")!,
                itemsWithQuantity: "Pizza slices (x10)",
                pickupDate: formatter.date(from: "2026-01-08 19:30")!,
                house: "12",
                road: "",
                block: "789",
                area: "Riffa",
                mobileNumber: "+97339998888"
            )
        ]
        
    }
}

// MARK: - TableView
extension HistoryViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return histories.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "HistoryCell",
            for: indexPath
        ) as! HistoryTableViewCell

        let history = histories[indexPath.row]
        cell.configure(with: history)

        // Handle details button tap
        cell.onDetailsTapped = { [weak self] in
            self?.selectedHistory = history
            self?.performSegue(withIdentifier: "goToHistoryDetails", sender: nil)
        }

        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToHistoryDetails",
           let detailsVC = segue.destination as? HistoryDetailsViewController {
            detailsVC.history = selectedHistory
        }
    }
}
