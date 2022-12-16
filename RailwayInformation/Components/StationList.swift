//
//  StationList.swift
//  RailwayInformation
//
//  Created by User20 on 2022/11/30.
//

import SwiftUI

struct StationList: View {
  @EnvironmentObject var dataController: DataController
  @State var selectedLine: Line? = nil
  @State var refreshTime: Date = Date()
  
  func refreshTrainLive() {
    dataController.queryTrainsLive()
    refreshTime = Date()
  }
  
  var body: some View {
    let filteredStations = dataController.stationsOfLine.first(
      where: { $0.LineID == selectedLine?.LineID }
    )?.Stations ?? []
    
    VStack(alignment: .leading) {
      Group {
        DisclosureGroup {
          LineChips(selected: $selectedLine, lines: dataController.lines.filter({ !$0.IsBranch }))
          LineChips(selected: $selectedLine, lines: dataController.lines.filter({ $0.IsBranch }))
        } label: {
          let lineName = selectedLine?.LineName.Zh_tw ?? "全部"
          let sectionName = selectedLine?.LineSectionName.Zh_tw ?? ""
          
          HStack(alignment: .bottom) {
            Text(lineName)
              .font(.title)
            
            Text(sectionName)
              .font(.subheadline)
              .foregroundColor(.secondary)
            
            Spacer()
          }
        }
        
        HStack(spacing: 0) {
          Spacer()
          
          Text(refreshTime, style: .relative)
          Text("前更新")
        }
        .font(.footnote)
        .foregroundColor(.secondary)
      }
      .padding(.horizontal)
      
      List {
        if(selectedLine == nil) {
          ForEach(dataController.stations) { x in
            StationRow(id: x.StationID, name: x.StationName)
          }
        } else {
          ForEach(filteredStations) { x in
            StationRow(id: x.StationID, name: x.StationName)
          }
        }
      }
      .onAppear(perform: refreshTrainLive)
      .onChange(of: selectedLine?.id, perform: { _ in refreshTrainLive() })
    }
  }
}

struct LineChips: View {
  @Binding var selected: Line?
  let lines: [Line]
  
  var body: some View {
    ScrollView(.horizontal, showsIndicators: false, content: {
      HStack(spacing: 24) {
        ForEach(lines) { x in
          let isSelected = selected?.id == x.id
          
          Button(x.LineName.Zh_tw) {
            selected = isSelected ? nil : x
          }
          .foregroundColor(isSelected ? .accentColor : .gray)
        }
      }
      .padding(.vertical, 2)
    })
  }
}

struct StationRow: View {
  @EnvironmentObject var dataController: DataController
  let id: String
  let name: Name
  
  var body: some View {
    let trains = dataController.trainsLive
      .filter({ $0.StationID == id })
    
    HStack {
      Text(name.Zh_tw)
      
      Spacer()
      
      ForEach(trains) { y in
        TrainLiveTag(train: y)
      }
    }
  }
}

struct TrainLiveTag: View {
  let train: TrainLive?
  
  var body: some View {
    HStack {
      Text(train?.TrainNo ?? "")
    }
  }
}
