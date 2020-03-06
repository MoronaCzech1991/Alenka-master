#include "AQuestionDialog.h"
#include "signalfilebrowserwindow.h"

AQuestionDialog::AQuestionDialog()
{
    this->MaintainMontage = false;
    this->TrackManager = false;
    this->EventTypeManager = false;
    this->setWindowTitle("Do you want to maintain the coniguration");

	// Labels
	TrackManagerLabel = new QLabel(this);
	TrackManagerLabel->setText("Track manager ");

    EventTypeManagerLabel = new QLabel(this);
    EventTypeManagerLabel->setText("EventType manager ");

    // Message = new QLabel(this);
    // Message->setText("Do you want to maintain the same coniguration");

    // MontageManagerLabel = new QLabel(this);
    // MontageManagerLabel->setText("Montage Manager");

    // FilterManagerLabel = new QLabel(this);
    // FilterManagerLabel->setText("Filter manager");

	// VideoPlayerLabel = new QLabel(this);
	// VideoPlayerLabel->setText("Video player");

	// Initiate the checkboxes
	TrackManagerCheck = new QCheckBox(this);
    EventTypeManagerCheck = new QCheckBox(this);
    // MontageManagerCheck = new QCheckBox(this);
    // FilterManagerCheck = new QCheckBox(this);
	// VideoPlayerCheck = new QCheckBox(this);

	ConfirmButton = new AButton();
	ConfirmButton->setText("Confirm");

	CancelButton = new AButton();
	CancelButton->setText("Cancel");

	MainLayout = new QGridLayout(this);
    MainLayout->addWidget(Message,0,0);
    MainLayout->addWidget(TrackManagerCheck,1,0);
    MainLayout->addWidget(TrackManagerLabel,1,1);

    MainLayout->addWidget(EventTypeManagerCheck, 1, 2);
    MainLayout->addWidget(EventTypeManagerLabel, 1, 3);

    // MainLayout->addWidget(MontageManagerCheck, 0, 2);
    // MainLayout->addWidget(MontageManagerLabel, 0, 3);
	
    // MainLayout->addWidget(FilterManagerCheck, 0, 4);
    // MainLayout->addWidget(FilterManagerLabel, 0, 5);

	// MainLayout->addWidget(VideoPlayerCheck, 0, 8);
	// MainLayout->addWidget(VideoPlayerLabel, 0, 9);

    MainLayout->addWidget(ConfirmButton, 2, 0, Qt::AlignLeft);
    MainLayout->addWidget(CancelButton, 2, 1, Qt::AlignRight);

	connect(ConfirmButton, SIGNAL(clicked(bool)), this, SLOT(ClickedConfirm(bool)));
	connect(CancelButton, SIGNAL(clicked(bool)), this, SLOT(ClickedCancel(bool)));
}

void AQuestionDialog::ClickedConfirm(bool checked)
{
     if(this->TrackManagerCheck || this->EventTypeManager)
         this->MaintainMontage = true;

	if (this->TrackManagerCheck)
		this->TrackManager = true;

    if (this->EventTypeManagerCheck)
        this->EventTypeManager = true;

    if(!this->TrackManagerCheck || !this->EventTypeManager)
    {
        this->TrackManager = false;
        this->EventTypeManager = false;
        this->MaintainMontage = false;
    }

	this->close();
}

void AQuestionDialog::ClickedCancel(bool checked)
{
	this->TrackManager = false;
    this->EventTypeManager = false;
    this->MaintainMontage = false;

	this->close();
}
